# LP Confirmable
Simple confirmable logic for Rails apps. No baked in routing or mailers, just the barebones logic and migration you need to implement confirmable logic for your users.

## Installation
Add `gem 'lp_confirmable',  github: 'launchpadlab/lp_confirmable'` to your Gemfile and run `bundle install`.

## Usage
For the purposes of these instructions, I will assume the model you are using is 'User' but it could be anything you want.

1. Generate a migration to add the required fields to the model of your choice with `bundle exec rails generate lp_confirmable:model User`
2. Run the migration with `bundle exec rails db:migrate`. This adds three columns to your table: `confirmation_token`, `confirmed_at`, and `confirmation_sent_at`.
3. When you want to start the process, assume you have created a `user`, then call `LpConfirmable::Model.set_confirmation_token! user`. This will return the token that you can share with the client via email, link, smoke-signals, whatever.
4. While you are in charge of sending confirmation instructions, `lp_confirmable` still needs to track it, so when you are ready call
```
LpConfirmable::Model.send_confirmation_instructions! user do
    <insert your logic here>
end
```
and 'lp_confirmable' will take care of the rest.

5. To confirm a user, call `LpConfirmable::Model.confirm_by_token!(User, confirmation_token)`. This will find the user by confirmation token and confirm them, returning the user model.
6. Any errors that pop up along the way, such as trying to confirm a non-confirmable object, or an expired token, etc..., will throw an `LpConfirmable::Error`.
7. To change the global defaults run `bundle exec rails generate lp_confirmable:install` to generate an initializer at `../config/initalizers/lp_confirmable.rb`. See the initializer for more details.

## Development
+ `git clone git@github.com:LaunchPadLab/lp_confirmable.git`
+ `bundle install`
+ Test with `rake`

## Confirm away!
