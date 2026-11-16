import assert from 'node:assert/strict';
import { after, before, test } from 'node:test';
import { createServer } from 'node:http';
import { readFile } from 'node:fs/promises';
import puppeteer from 'puppeteer';

const assets = new URL('../../docker/review/account-picker/', import.meta.url);
const authorization = '?client_id=review-pr-123&state=state-123&nonce=nonce-123';
const simulatorForm = `<form action="/form-submit" method="post">
  <input name="authCode" value="code-123">
  <input name="authRequestParams" value="request-123">
  <input name="state" value="state-123">
  <input name="sub" value="default-sub">
  <input name="email" value="default@example.com">
  <input name="emailVerified" type="checkbox" value="true" checked>
  <textarea name="coreIdentityVerifiableCredentials">{"test":true}</textarea>
</form>`;
let browser;
let server;
let origin;
let simulatorStatus;
let simulatorHtml;
let authorizationRequests;
let submitted;

before(async () => {
  server = createServer(async (request, response) => {
    const url = new URL(request.url, 'http://localhost');
    if (url.pathname === '/review-login/authorize') {
      authorizationRequests.push(url.search);
      response.writeHead(simulatorStatus, { 'Content-Type': 'text/html' });
      response.end(simulatorHtml);
    } else if (url.pathname === '/form-submit') {
      let body = '';
      for await (const chunk of request) body += chunk;
      submitted = new URLSearchParams(body);
      response.end('Signed in');
    } else {
      const file = {
        '/authorize': ['index.html', 'text/html'],
        '/review-login/picker.js': ['picker.js', 'text/javascript'],
        '/review-login/picker.css': ['picker.css', 'text/css'],
      }[url.pathname];
      if (!file) {
        response.writeHead(404);
        response.end();
        return;
      }
      response.writeHead(200, { 'Content-Type': file[1] });
      response.end(await readFile(new URL(file[0], assets)));
    }
  });
  await new Promise(resolve => server.listen(0, '127.0.0.1', resolve));
  origin = `http://127.0.0.1:${server.address().port}`;
  browser = await puppeteer.launch({ headless: true, args: process.env.CI ? ['--no-sandbox'] : [] });
});

after(async () => {
  await browser?.close();
  if (server) await new Promise(resolve => server.close(resolve));
});

async function withPicker(run) {
  simulatorStatus = 200;
  simulatorHtml = simulatorForm;
  authorizationRequests = [];
  submitted = undefined;
  const context = await browser.createBrowserContext();
  try {
    const page = await context.newPage();
    page.setDefaultTimeout(5000);
    await page.goto(`${origin}/authorize${authorization}`);
    await run(page);
  } finally {
    await context.close();
  }
}

async function signIn(page) {
  await Promise.all([page.waitForNavigation(), page.click('#sign-in')]);
}

test('creates unique accounts that fit the input and hides technical fields', async () => {
  await withPicker(async page => {
    assert.equal(await page.$('[name="sub"], [name="email"], textarea'), null);
    await page.click('#create-account');
    const first = await page.$eval('#account-name', input => input.value);
    assert.match(first, /^test-[a-f0-9]{32}$/);
    assert.equal(await page.$eval('#account-name', input => input.checkValidity()), true);
    await page.click('#create-account');
    const second = await page.$eval('#account-name', input => input.value);
    assert.notEqual(first, second);
    await signIn(page);
    assert.equal(submitted.get('sub'), `review-${second}`);
    assert.equal(submitted.get('email'), `${second}@example.com`);
  });
});

test('reuses named accounts across fresh sessions and preserves the OIDC form', async () => {
  for (let login = 0; login < 2; login++) {
    await withPicker(async page => {
      await page.type('#account-name', 'alex-test');
      await signIn(page);
      assert.deepEqual(authorizationRequests, [authorization]);
      assert.equal(submitted.get('sub'), 'review-alex-test');
      assert.equal(submitted.get('email'), 'alex-test@example.com');
      assert.equal(submitted.get('emailVerified'), 'true');
      assert.equal(submitted.get('authCode'), 'code-123');
      assert.equal(submitted.get('authRequestParams'), 'request-123');
      assert.equal(submitted.get('state'), 'state-123');
      assert.equal(submitted.get('coreIdentityVerifiableCredentials'), '{"test":true}');
      assert.equal(submitted.get('continue'), 'continue');
    });
  }
});

test('rejects invalid names before contacting the simulator', async () => {
  await withPicker(async page => {
    for (const name of ['', 'Real Person@example.com', '../invalid', 'a'.repeat(41)]) {
      await page.$eval('#account-name', (input, value) => { input.value = value; }, name);
      assert.equal(await page.$eval('#account-name', input => input.checkValidity()), false);
    }
    assert.equal(await page.$eval('#account-name', input => input.maxLength), 40);
    await page.$eval('#account-name', input => { input.value = ''; });
    await page.click('#sign-in');
    assert.deepEqual(authorizationRequests, []);
    assert.equal(submitted, undefined);
  });
});

test('reports simulator errors and allows retry without changing account', async () => {
  await withPicker(async page => {
    simulatorStatus = 503;
    await page.type('#account-name', 'alex-test');
    await page.click('#sign-in');
    await page.waitForSelector('#error:not([hidden])');
    assert.match(await page.$eval('#error', element => element.textContent), /HTTP 503/);
    assert.equal(await page.$eval('#sign-in', button => button.disabled), false);
    simulatorStatus = 200;
    await signIn(page);
    assert.equal(submitted.get('sub'), 'review-alex-test');
  });
});

test('reports an incompatible simulator form instead of submitting it', async () => {
  await withPicker(async page => {
    simulatorHtml = '<form action="https://example.com/form-submit" method="post"></form>';
    await page.type('#account-name', 'alex-test');
    await page.click('#sign-in');
    await page.waitForSelector('#error:not([hidden])');
    assert.match(await page.$eval('#error', element => element.textContent), /unexpected form/);
    assert.equal(submitted, undefined);
  });
});
