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

  Training::Module.ordered.each do |mod|
    add about_path(mod.name)
  end


  # GOV.UK one login
  add gov_one_info_path

  # devise
  add new_user_unlock_path
  add new_user_confirmation_path
  add new_user_registration_path
  add new_user_session_path
  add check_email_confirmation_user_path
  add check_email_password_reset_user_path

  # private pages
  # ------------------------------------------

  # account
  add user_path

  # edit registration/account
  add edit_email_user_path
  add edit_password_user_path
  add edit_registration_terms_and_conditions_path
  add edit_registration_name_path
  add edit_registration_setting_type_path
  add edit_registration_setting_type_other_path
  add edit_registration_local_authority_path
  add edit_registration_role_type_path
  add edit_registration_role_type_other_path
  add edit_registration_training_emails_path
  add edit_registration_early_years_emails_path

  # close account
  add edit_reason_user_close_account_path
  add confirm_user_close_account_path
  add new_user_close_account_path
  add user_close_account_path

  # learning
  add my_modules_path
  add user_notes_path

  # Course content
  Training::Module.ordered.each do |mod|
    mod.content.each do |page|
      if page.is_question?
        add training_module_question_path(mod.name, page.name)
      elsif page.assessment_results?
        add training_module_assessment_path(mod.name, page.name)
      else
        add training_module_page_path(mod.name, page.name)
      end
    end
  end
end
