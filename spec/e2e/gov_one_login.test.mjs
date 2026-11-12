import assert from 'node:assert/strict';
import { after, before, test } from 'node:test';
import { mkdir, writeFile } from 'node:fs/promises';
import { randomUUID } from 'node:crypto';
import puppeteer from 'puppeteer';

const review = Boolean(process.env.REVIEW_APP_URL);
const appUrl = (process.env.REVIEW_APP_URL || 'http://localhost:3001').replace(/\/$/, '');
const simulatorUrl = review ? appUrl : 'http://localhost:4001';
const clientId = review ? process.env.GOV_ONE_CLIENT_ID : 'cdt-login-e2e';
const identity = `login-e2e-${randomUUID()}`;
const termsPath = '/registration/terms-and-conditions/edit';
let browser;

before(async () => {
  if (review) {
    assert.equal(new URL(appUrl).protocol, 'https:');
    assert.match(clientId, /^review-pr-\d+$/);
  } else {
    assert.equal(process.env.RAILS_ENV, 'test', 'Run this test with bash bin/login-e2e');
    assert.equal(process.env.ENVIRONMENT, 'test');
    assert.equal(process.env.GOV_ONE_BASE_URI, simulatorUrl);
  }
  await mkdir('tmp/login-e2e', { recursive: true });

  browser = await puppeteer.launch({
    headless: true,
    args: process.env.CI ? ['--no-sandbox'] : [],
  });
});

after(async () => {
  await browser?.close();
});

test('signs in through One Login and reuses the account in a fresh browser session', { timeout: 90_000 }, async () => {
  for (const returningUser of [false, true]) {
    const context = await browser.createBrowserContext();
    const page = await context.newPage();
    page.setDefaultTimeout(20_000);
    const diagnostics = [];
    page.on('pageerror', error => diagnostics.push(error.message));
    page.on('requestfailed', request => diagnostics.push(`${new URL(request.url()).pathname}: ${request.failure()?.errorText}`));

    try {
      const protectedResponse = await page.goto(`${appUrl}${termsPath}`);
      assert.equal(protectedResponse.status(), 200);
      assert.equal(new URL(page.url()).pathname, '/users/sign-in', 'Registration requires a signed-in session');

      const link = await page.waitForSelector(`a[href^="${simulatorUrl}/authorize?"]`);
      const authorizeUrl = new URL(await link.evaluate(element => element.href));
      assert.equal(authorizeUrl.searchParams.get('client_id'), clientId);
      assert.equal(authorizeUrl.searchParams.get('redirect_uri'), `${appUrl}/users/auth/openid_connect/callback`);
      assert.equal(authorizeUrl.searchParams.get('response_type'), 'code');

      await Promise.all([
        page.waitForNavigation({ waitUntil: 'networkidle0' }),
        link.click(),
      ]);
      assert.equal(new URL(page.url()).pathname, '/authorize');
      await page.waitForSelector('[data-testid="sub"]');
      await page.$eval('[data-testid="sub"]', (element, value) => { element.value = value; }, identity);
      await page.$eval('[data-testid="email"]', (element, value) => { element.value = value; }, `${identity}@example.com`);

      const callbackResponse = page.waitForResponse(response => {
        const url = new URL(response.url());
        return url.origin === appUrl && url.pathname === '/users/auth/openid_connect/callback';
      });
      const [callback] = await Promise.all([
        callbackResponse,
        page.waitForNavigation({ waitUntil: 'networkidle0' }),
        page.click('button[name="continue"]'),
      ]);

      assert.equal(callback.status(), 302, 'The real OIDC callback redirects after token validation');
      assert.equal(page.url(), `${appUrl}${termsPath}`);

      if (!returningUser) {
        const checkbox = await page.waitForSelector('input[type="checkbox"][name="user[terms_and_conditions_agreed_at]"]');
        await checkbox.click();
        assert.equal(await checkbox.evaluate(element => element.checked), true);
        await Promise.all([
          page.waitForNavigation({ waitUntil: 'networkidle0' }),
          page.click('#main-content input[type="submit"], #main-content button[type="submit"]'),
        ]);
        assert.equal(new URL(page.url()).pathname, '/registration/name/edit', 'The authenticated user can update their account');
        await page.type('input[name="user[first_name]"]', 'Login');
        await page.type('input[name="user[last_name]"]', 'Test');
        await Promise.all([
          page.waitForNavigation({ waitUntil: 'networkidle0' }),
          page.click('#main-content input[type="submit"], #main-content button[type="submit"]'),
        ]);
        assert.equal(new URL(page.url()).pathname, '/registration/where-you-live/edit');
      }

      await page.goto(`${appUrl}/registration/name/edit`);
      const firstName = await page.$eval('input[name="user[first_name]"]', element => element.value);
      const lastName = await page.$eval('input[name="user[last_name]"]', element => element.value);
      assert.equal(firstName, 'Login', 'Account data persists across logins');
      assert.equal(lastName, 'Test');

      const response = await page.goto(`${appUrl}${termsPath}`);
      assert.equal(response.status(), 200);
      assert.equal(page.url(), `${appUrl}${termsPath}`, 'The signed-in session survives another request');

      const logoutLink = await page.waitForSelector(`a[href^="${simulatorUrl}/logout?"]`);
      const logoutUrl = new URL(await logoutLink.evaluate(element => element.href));
      assert.equal(logoutUrl.searchParams.get('post_logout_redirect_uri'), `${appUrl}/users/sign_out`);
      const logoutCallback = page.waitForResponse(response => {
        const url = new URL(response.url());
        return url.origin === appUrl && url.pathname === '/users/sign_out';
      });
      const [logoutResponse] = await Promise.all([
        logoutCallback,
        page.waitForNavigation({ waitUntil: 'networkidle0' }),
        logoutLink.click(),
      ]);
      assert.equal(logoutResponse.status(), 303, 'Devise redirects after destroying the session');
      await page.goto(`${appUrl}${termsPath}`);
      assert.equal(new URL(page.url()).pathname, '/users/sign-in', 'Explicit logout removes authenticated access');
    } catch (error) {
      const path = `tmp/login-e2e/${returningUser ? 'returning' : 'new'}-user`;
      await page.screenshot({ path: `${path}.png`, fullPage: true });
      await writeFile(`${path}.html`, await page.content());
      await writeFile(`${path}.json`, JSON.stringify({ pathname: new URL(page.url()).pathname, diagnostics }, null, 2));
      throw error;
    } finally {
      await context.close();
    }
  }
});
