module GHX
  class GHXError < StandardError; end
  class RateLimitExceededError < GHXError; end
  class OtherApiError < GHXError; end
end