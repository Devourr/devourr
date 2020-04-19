module ApplicationHelper
  include User::ProfileHelper

  def current_path
    request.path
  end

  # render flash messages
  # https://onehundredairports.com/2017/04/05/creating-multiple-flash-messages-in-ruby-on-rails/
  def render_flash(type, text)
    render partial: 'layouts/flash', locals: { type: type.to_s, text: text }
  end

  #   Since my messages can have different priorities, when I display a page with multiple messages, I want them sorted with the highest priorities first. My order array defines the order I want my types sorted in.

  # Next, I make sure a @messages array exists, and then I merge any flash messages into my messages array, so they display the same as any other message. For each flash, the hash’s key is used as the type.

  # Then, I get the index of each message type in my order array, and sort on that. If a message has a type that’s not in the array, it’s given an order number of the length of the array. Since that number will always be higher than any array index, the unknown message types will be sorted below the defined message types.

  # Finally, I loop through the messages with map, call render_flash to render the message partial for each, and then join all the partials together. Since this is the last operation of the method, this string of joined message partials will be returned by render_flashs.
  def render_flashes
    order = [:error, :errors, :alert, :warning, :notice, :success, :info]
    @messages ||= []

    flash_messages = []
    flash&.map do |type, text|
      # https://github.com/heartcombo/devise/issues/1777
      next if type == 'timedout'

      if text.is_a? String
        flash_messages << { type: type.to_sym, text: text }
      else
        # raising errors like this
        # flash[:errors] = @user.errors.full_messages
        # requires iterating through array of errors
        text.map do |t|
          flash_messages << { type: type.to_sym, text: t }
        end
      end
    end

    @messages.concat(flash_messages)

    ordered_messages = @messages.sort_by do |message|
      order.index(message[:type]) || order.length
    end

    ordered_messages.map do |message|
      render_flash(message[:type], message[:text])
    end.join.html_safe

    # @messages.concat(flash.map{|k,v| {type: k.to_sym, text: v}}) if flash
    # @messages.sort_by{|m| order.index(m[:type]) || order.length}
    #   .map{|m| render_flash(m[:type], m[:text]) }.join.html_safe
  end
end
