require 'lp_confirmable/error'

module LpConfirmable
  module Model
    module ClassMethods
      def confirm_by_token!(klass, confirmation_token)

        check_confirmable! klass

        model = klass.find_by(confirmation_token: confirmation_token)

        check_token_active! model

        model.update_columns(
          confirmation_token: nil,
          confirmed_at: Time.current,
        )

        model
      end

      def set_confirmation_token!(model)

        check_confirmable! model.class

        confirmation_token = generate_confirmation_token Config.token_length

        model.update_columns(confirmation_token: confirmation_token)

        confirmation_token
      end

      def send_confirmation_instructions(model)

        check_confirmable! model.class

        check_confirmation_not_sent! model

        yield

        model.update_columns(confirmation_sent_at: Time.current)
      end

      def check_confirmable!(klass)
        raise Error, "#{klass} not confirmable" unless confirmable?(klass)
      end

      def confirmable?(klass)
        %q(
          confirmation_token
          confirmed_at
          confirmation_sent_at
        ).all? { |attr| klass.column_names.include? attr }
      end

      def check_token_active!(model)
        raise Error, 'confirmation token expired' unless token_active?(model)
      end

      def token_active?(model)
        Time.current <= (model.confirmation_sent_at + Config.token_lifetime)
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
