require 'lp_confirmable/error'
require 'securerandom'

module LpConfirmable
  class Model
    class << self
      def confirm_by_token!(klass, confirmation_token)

        check_confirmable! klass

        model = klass.find_by(confirmation_token: confirmation_token)

        check_token_active! model

        model.update_columns(
          confirmation_token: nil,
          confirmed_at: Time.now,
        )

        model
      end

      def set_confirmation_token!(model, token_length=LpConfirmable.config.token_length)

        check_confirmable! model.class

        confirmation_token = generate_confirmation_token token_length

        model.update_columns(
          confirmation_token: confirmation_token,
          confirmed_at: nil,
          confirmation_sent_at: nil,
        )

        confirmation_token
      end

      def send_confirmation_instructions!(model)

        check_confirmable! model.class

        check_confirmation_not_sent! model

        yield if block_given?

        model.update_columns(confirmation_sent_at: Time.now)
      end

      def check_confirmable!(klass)
        raise Error, "#{klass} not confirmable" unless confirmable?(klass)
      end

      def confirmable?(klass)

        return false unless klass.respond_to? :column_names

        column_names = klass.column_names

        %w(
          confirmation_token
          confirmed_at
          confirmation_sent_at
        ).all? { |attr| column_names.include? attr }
      end

      def check_token_active!(model)
        raise Error, 'confirmation token not found' unless model
        raise Error, 'confirmation token expired' unless token_active?(model)
      end

      def token_active?(model)
        model.confirmation_token &&
        model.confirmation_sent_at &&
        Time.now <= (model.confirmation_sent_at + (LpConfirmable.config.token_lifetime * 60 * 60 * 24))
      end

      def check_confirmation_not_sent!(model)
        raise Error, 'confirmation already sent' unless confirmation_not_sent?(model)
      end

      def confirmation_not_sent?(model)
        model.confirmation_sent_at == nil
      end

      def generate_confirmation_token(length)
        rlength = (length * 3) / 4
        SecureRandom.urlsafe_base64(rlength).tr('lIO0', 'sxyz')
      end
    end
  end
end
