# Calls to this class are intercepted by the RoutingError
# on the API::BaseController. We could (and used to) route
# to that file, but I prefer keeping it abstract and having
# a file we can look for in the logs directly here.

module API
  class ErrorsController < BaseController
  end
end
