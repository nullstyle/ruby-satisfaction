require 'rubygems'
require 'active_support'
require 'hpricot'
require 'json'
require 'json/add/rails'  #make json play nice with the json rails outputs
gem('memcache-client')
require 'memcache'

require 'oauth'
require 'oauth/signature/hmac/sha1'
require 'oauth/client/net_http'
