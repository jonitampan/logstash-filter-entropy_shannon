require "logstash/filters/base"
require "logstash/namespace"
require "shannon"
# This  filter will replace the contents of the default
# message field with whatever you specify in the configuration.
#
# It is only intended to be used as an .
class LogStash::Filters::EntropyShannon < LogStash::Filters::Base

  config_name "entropy_shannon"
  config :entropy_check, :validate => :array
  config :str_check, :validate => :array, :default => [ "rudukmada.com"]
  config :uppercase, :validate => :array

  public
  def register
    # Add instance variables
  end # def register

  public
  def filter(event)
    entropy_check(event) if @entropy_check
    # Replace the event message with our message as configured in the
    # config file.

    # filter_matched should go in the last line of our successful code
    filter_matched(event)
  end # def filter

  def entropy_check(event)
    @entropy_check.each do |field|
      original = event.get(field)
      next if original.nil?
      # in certain cases JRuby returns a proxy wrapper of the event[field] value
      # therefore we can't assume that we are modifying the actual value behind
      # the key so read, modify and overwrite
      result = case original
        when Array
          original.map do |elem|             
            ctk = Shannon::entropy(elem).round 4
            (elem.is_a?(String) ? ctk : elem)
          end
        when String
          Shannon::entropy(original).round 4
        else
          @logger.debug? && @logger.debug("Can't calculate something that isn't a string", :field => field, :value => original)
          original
        end
      event.set(field, result)
    end
  end



end # class LogStash::Filters::EntropyShannon
