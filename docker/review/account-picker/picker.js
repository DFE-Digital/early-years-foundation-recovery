const picker = document.querySelector('#account-picker');
const account = document.querySelector('#account-name');
const signIn = document.querySelector('#sign-in');
const createAccount = document.querySelector('#create-account');
const error = document.querySelector('#error');

createAccount.addEventListener('click', () => {
  account.value = `test-${crypto.randomUUID().replaceAll('-', '')}`;
  document.querySelector('#new-account').textContent = `Your new account name is ${account.value}. Select "Sign in with this test account" to continue.`;
  account.focus();
});

picker.addEventListener('submit', async event => {
  event.preventDefault();
  const accountName = account.value;
  error.hidden = true;
  signIn.disabled = true;
  createAccount.disabled = true;
  signIn.textContent = 'Signing in...';

  try {
    const response = await fetch(`/review-login/authorize${window.location.search}`, { cache: 'no-store' });
    if (!response.ok) throw new Error(`The sign-in simulator returned HTTP ${response.status}.`);

    const document = new DOMParser().parseFromString(await response.text(), 'text/html');
    const simulatorForm = document.querySelector('form');
    const action = simulatorForm && new URL(simulatorForm.getAttribute('action'), window.location.origin);
    if (!action || action.origin !== window.location.origin || action.pathname !== '/form-submit' ||
        simulatorForm.method.toLowerCase() !== 'post' ||
        !simulatorForm.querySelector('input[name="authCode"]') ||
        !simulatorForm.querySelector('input[name="authRequestParams"]')) {
      throw new Error('The sign-in simulator returned an unexpected form.');
    }

    const fields = new FormData(simulatorForm);
    fields.set('sub', `review-${accountName}`);
    fields.set('email', `${accountName}@example.com`);
    fields.set('emailVerified', 'true');
    fields.set('continue', 'continue');

    const form = window.document.createElement('form');
    form.method = 'post';
    form.action = '/form-submit';
    form.hidden = true;
    for (const [name, value] of fields) {
      const input = window.document.createElement('input');
      input.type = 'hidden';
      input.name = name;
      input.value = value;
      form.append(input);
    }
    window.document.body.append(form);
    form.submit();
  } catch (failure) {
    error.textContent = `${failure.message} Try again. If this continues, ask the development team to check the review app.`;
    error.hidden = false;
    signIn.disabled = false;
    createAccount.disabled = false;
    signIn.textContent = 'Sign in with this test account';
  }
});
