if defined?(BetterErrors)
  # Enable BetterErrors within Docker
  BetterErrors::Middleware.allow_ip! "0.0.0.0/0"
end
