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
protocol = Rails.env.production? ? 'https://' : 'http://'
SitemapGenerator::Sitemap.default_host = protocol + ENV['DOMAIN']
SitemapGenerator::Sitemap.compress = false

# Run this command to update /public/sitemap.xml
#
# ./bin/docker-rails sitemap:refresh:no_ping
#
# NB: `app._routes.named_routes.helper_names`
#
SitemapGenerator::Sitemap.create do
  # TODO: test dynamic page content like question feedback

  # non-course pages
  %w[
    accessibility-statement
    new-registration
    other-problems-signing-in
    privacy-policy
    promotional-materials
    sitemap
    terms-and-conditions
    whats-new
    wifi-and-data
  ].each do |path|
    add static_path(path)
  end

  # settings
  add setting_path('cookie-policy')

  # errors
  add '/404'
  add '/422'
  add '/500'

  add users_timeout_path

  add course_overview_path

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
  add edit_registration_name_path
  add edit_registration_setting_type_path
  add edit_registration_setting_type_other_path
  add edit_registration_local_authority_path
  add edit_registration_role_type_path
  add edit_registration_role_type_other_path

  # close account
  add edit_reason_user_close_account_path
  add confirm_user_close_account_path
  add new_user_close_account_path
  add user_close_account_path

  # learning
  add my_modules_path
  add user_notes_path

  # Representative content
  mod = Rails.application.cms? ? Training::Module.ordered.first : TrainingModule.published.first
  add training_module_path(mod.name)
  add training_module_content_page_path(mod.name, mod.interruption_page.name)
  add training_module_content_page_path(mod.name, mod.first_content_page.name)
  # add training_module_content_page_path(mod, mod.text_pages.first) # for CMS
  add training_module_content_page_path(mod.name, mod.video_pages.first.name)
  add training_module_content_page_path(mod.name, mod.summary_intro_page.name)
  add training_module_content_page_path(mod.name, mod.assessment_intro_page.name)
  add training_module_content_page_path(mod.name, mod.confidence_intro_page.name)
  add training_module_content_page_path(mod.name, mod.thankyou_page.name)
  add training_module_content_page_path(mod.name, mod.certificate_page.name)
  add training_module_questionnaire_path(mod.name, mod.formative_questions.first.name)
  add training_module_questionnaire_path(mod.name, mod.summative_questions.first.name)
  add training_module_questionnaire_path(mod.name, mod.confidence_questions.first.name)
  add training_module_assessment_result_path(mod.name, mod.assessment_results_page.name)

  # All content
  # mods = Rails.application.cms? ? Training::Module.ordered : TrainingModule.published
  # mods.each do |mod|
  #   mod.module_items.each do |page|
  #     if page.is_question?
  #       add training_module_questionnaire_path(mod.name, page.name)
  #     elsif page.assessment_results?
  #       add training_module_assessment_result_path(mod.name, page.name)
  #     else
  #       add training_module_content_page_path(mod.name, page.name)
  #     end
  #   end
  # end
end
