library(auth0)

auth0_server(function(input, output, session) {
  observe({ print(session$userData$auth0_info) })
}, info = a0_info)
