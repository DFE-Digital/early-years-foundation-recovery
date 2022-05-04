module TranslateFromLocale
  # @return [String]
  def translate(label)
    # Suppress translation returning "translation missing" message so validation for presence works
    return unless I18n.exists?([i18n_scope, label])

    I18n.t(label, scope: i18n_scope)
  end

  # @return [Array<Symbol>]
  def i18n_scope
    [:modules, training_module, name]
  end
end
