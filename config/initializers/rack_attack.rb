# TODO: prepare throttling security
# https://learn.onemonth.com/defensive-hacking-how-to-prevent-a-brute-force-attack/

# Rack::Attack.throttle("requests by ip", limit: 5, period: 2) do |request|
#   request.ip
# end

# # Throttle login attempts for a given email parameter to 6 reqs/minute
# # Return the email as a discriminator on POST /login requests
# Rack::Attack.throttle('limit logins per email', limit: 6, period: 60) do |req|
#   if req.path == '/login' && req.post?
#     req.params['email']
#   end
# end

# # You can also set a limit and period using a proc. For instance, after
# # Rack::Auth::Basic has authenticated the user:
# limit_proc = proc { |req| req.env["REMOTE_USER"] == "admin" ? 100 : 1 }
# period_proc = proc { |req| req.env["REMOTE_USER"] == "admin" ? 1 : 60 }

# Rack::Attack.throttle('request per ip', limit: limit_proc, period: period_proc) do |request|
#   request.ip
# end
