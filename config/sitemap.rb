# Example of automated authentication in pa11y-ci config:
#
#   "urls": [
#     {
#       "url": "http://app:3000/my-modules",
#       "actions": [
#         "wait for path to be /users/sign-in",
#         "set field #user-email-field to completed@example.com",
#         "set field #user-password-field to StrongPassword",
#         "click element #sign-in",
#         "wait for element h2#govuk-notification-banner-title to be visible",
#         "screen capture /tmp/images/my-modules.png"
#       ]
#     }
#   ]
#
SitemapGenerator::Sitemap.default_host = Rails.application.config.service_url
SitemapGenerator::Sitemap.compress = false

# Run this command to update /public/sitemap.xml
#
# ./bin/docker-rails sitemap:refresh:no_ping
#
# NB: `app._routes.named_routes.helper_names`
#
SitemapGenerator::Sitemap.create do
  # TODO: test dynamic page content like question feedback

  # static pages
  Page.order(:heading).load.each do |page|
    add static_path(page.name)
  end

  # settings
  add setting_path('cookie-policy')

  # errors
  add '/404'
  # add '/422'
  add '/500'

  add users_timeout_path

  add course_overview_path
  add experts_path

  Training::Module.live.each do |mod|
    add about_path(mod.name)
  end

  add new_user_session_path

  # private pages
  # ------------------------------------------

  # account
  add user_path

  # edit registration/account
  add edit_registration_terms_and_conditions_path
  add edit_registration_name_path # unless Rails.application.gov_one_login?
  add edit_registration_setting_type_path
  add edit_registration_setting_type_other_path
  add edit_registration_local_authority_path
  add edit_registration_role_type_path
  add edit_registration_role_type_other_path
  add edit_registration_early_years_experience_path
  add edit_registration_training_emails_path
  add edit_registration_early_years_emails_path

  # close account
  add edit_reason_user_close_account_path
  add confirm_user_close_account_path
  add user_close_account_path

  # learning
  add my_modules_path
  add user_notes_path

  # Course common start page
  mod = Training::Module.live.first
  add training_module_page_path(mod.name, mod.pages.first.name)

  # Course content random module
  Training::Module.live.sample.content.each do |page|
    if page.is_question?
      add training_module_question_path(page.parent.name, page.name)
    elsif page.assessment_results?
      add training_module_assessment_path(page.parent.name, page.name)
    else
      add training_module_page_path(page.parent.name, page.name)
    end
  end
end
