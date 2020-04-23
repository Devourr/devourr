require 'rails_helper'

# this could be done from the devise/registration_spec,
# but opting for separate file
RSpec.describe 'User edit', type: :feature do

  let(:user) { create(:user, :confirmed) }
  let(:required_params) { ['name', 'user_name', 'email']}
  let(:user_name_invalid_error_message) { 'Usernames can only use letters, numbers, underscores and periods.' }

  # for testing mailers
  # https://www.lucascaton.com.br/2010/10/25/how-to-test-mailers-in-rails-with-rspec/

  # I'm going crazy these variables are inconsistently nil ???
  # just going to code slightly less efficiently below
  # skipping below and may revisit later if necessary
  # interesting this is nil; must be reserved
  let(:new_email_user_params) { 'new@email.com' }
  # copied value to new variable seems to work {{ôvô?}}
  # actually this became nil, and now ^ works...
  let(:brand_new_email) { 'new@email.com' }


  before(:each) do
    sign_in user
    visit edit_profile_path(user.user_name)
  end

  context 'non-existing user' do
    it 'redirects to root path' do
      visit edit_profile_path('nobody')
      expect_root_path
      expect(page).to have_content 'Requested page is not available.'
    end
  end

  context 'existing user' do

    it 'redirects if requested by id' do
      visit "/#{user.id}/edit"
      expect_root_path
      expect(page).to have_content 'Requested page is not available.'
    end

    it 'has content' do
      within '#header' do
        expect(page).to have_link('Edit password', href: "/#{user.user_name}/account/edit")
      end

      within '#content' do
        expect(page).to have_content("Edit Profile")
      end
    end

    context 'update fails' do

      it 'missing attributes' do
        required_params.map do |skip_param|
          fill_edit_profile_form skip_param
          expect_update_profile_fails
          visit edit_profile_path(user.user_name)
          # todo: expect errors
        end
      end

      context 'invalid attributes' do

        context 'blank attributes' do
          it 'name' do
            fill_edit_profile_form 'name'
            expect_update_profile_fails
            expect(page).to have_css('.flash', text: "Name can't be blank")
          end

          it 'user name' do
            fill_edit_profile_form 'user_name'
            expect_update_profile_fails
            expect(page).to have_css('.flash', text: "User name can't be blank")
            expect(page).to have_css('.flash', text: user_name_invalid_error_message)
          end

          it 'email' do
            fill_edit_profile_form 'email'
            expect_update_profile_fails
            expect(page).to have_css('.flash', text: "Email can't be blank")
          end
        end

        context 'name' do
          it 'too long' do
            fill_in 'Name', with: 'a' * 71 # => 71 chars
            expect_update_profile_fails
            expect(page).to have_content 'Name is too long (maximum is 70 characters)'
          end
        end

        context 'user_name' do
          it 'not unique' do
            other_user = create(:user, :confirmed)
            fill_in 'Username', with: other_user.user_name
            expect_update_profile_fails
            expect(page).to have_css('.flash', text: "User name has already been taken")
          end

          it 'special character' do
            fill_in 'Username', with: 'user1234!'
            expect_update_profile_fails
            expect(page).to have_css('.flash', text: user_name_invalid_error_message)
          end

          it 'hyphen' do
            fill_in 'Username', with: 'user-1234'
            expect_update_profile_fails
            expect(page).to have_css('.flash', text: user_name_invalid_error_message)
          end

          it 'space' do
            fill_in 'Username', with: 'user 1234'
            expect_update_profile_fails
            expect(page).to have_css('.flash', text: user_name_invalid_error_message)
          end

          it 'too long' do
            # 30 for Instagram, 15 for Twitter
            fill_in 'Username', with: 'a' * 31 # => 31 chars
            expect_update_profile_fails
            expect(page).to have_css('.flash', text: 'User name is too long (maximum is 30 characters)')
          end

          # prevent user names being taken that could belong to route paths
          # or reserved or offensive
          it 'blocked' do
            blocked_user_name = create(:blocked_user_name, user_name: 'admin')
            fill_in 'Username', with: blocked_user_name.user_name
            expect_update_profile_fails
            expect(page).to have_css('.flash', text: 'Username is not available')
          end
        end

        context 'non-unique user attributes' do
          it 'matching user_name' do
            existing_user = create(:user, :confirmed)
            fill_edit_profile_form
            fill_in 'Username', with: existing_user.user_name
            expect_update_profile_fails
            expect(page).to have_css('.flash', text: 'User name has already been taken')
          end

          context 'matching email' do

            before(:each) do
              existing_user = create(:user, :confirmed)
              existing_user_email = existing_user.email
              fill_edit_profile_form
              fill_in 'Email', with: existing_user_email
            end

            it 'displays success so no leaking valid emails' do
              expect_update_profile_succeeds
              expect_email_change_success_message(existing_user_email)
            end

            it 'not send confirmation email to new email' do
              expect do
                expect_update_profile_succeeds
              end.to change { ActionMailer::Base.deliveries.count }.by(1)
              expect_email_change_to_send_confirmation_instructions
            end
            # send confirmation email to old email

          end
        end
      end
    end

    context 'update succeeds' do
      context 'email' do
        it 'shows message to confirm new email' do
          fill_edit_profile_form
          expect_update_profile_succeeds
          expect_email_change_success_message('new@email.com')
        end

        # https://www.lucascaton.com.br/2010/10/25/how-to-test-mailers-in-rails-with-rspec/
        it 'sends confirmation email to new address' do
          fill_edit_profile_form
          expect do
            click_button 'Update'
          end.to change { ActionMailer::Base.deliveries.count }.by(1)
          expect_email_change_to_send_confirmation_instructions
        end

        # TODO: add email change warning email
        # flow could be to just send email to old email upon email changing
        # then add 'todo' to send email change warning email
        # interesting point regarding credential stuffing
        # https://ux.stackexchange.com/questions/58503/best-practices-for-a-change-of-email-user#comment208779_58553
        # will want to have link in email warning/confirmation
        # to old email to revert --> perhaps add `old_email` column
        xit 'sends confirmation email to old address' do
        end

        # request change multiple times (typo)
        it 'request email change multiple times (typo)' do
          fill_edit_profile_form
          click_button 'Update'
          click_link 'Change this'
          user.reload
          expect(current_path).to eq edit_profile_path(user.user_name)
          new_new_email = 'new2@email.com'
          fill_in 'Email', with: new_new_email
          click_button 'Update'
          expect_email_change_success_message(new_new_email)
          user.reload
          expect(user.unconfirmed_email).to eq new_new_email
        end

        it 'allows confirmation of new email' do
          old_email = user.email
          fill_edit_profile_form
          click_button 'Update'

          # expect email to not change yet
          user.reload
          new_email = 'new@email.com'
          expect(user.email).to eq old_email
          expect(user.unconfirmed_email).to eq new_email

          # click email link
          visit user_confirmation_path({ confirmation_token: user.confirmation_token })
          expect_confirmation_succeeds

          # email is updated
          user.reload
          expect(user.email).to eq new_email

          # redirect to root_path, not login page
          expect(current_path).to eq root_path

          # sign out, then back in with new email
          sign_out user
          expect_login_success
        end



        # if user makes a typo in email change
        # https://ux.stackexchange.com/a/105809

        # request change but don't change, sign in with old email
        # request change and don't confirm, sign in with new email
        # request change and confirm, sign in with new email
        # request change and confirm, sign in with new email, then revert back to old email
      end
    end
  end

  def fill_edit_profile_form(skip_param = nil)
    fill_in 'Name', with: skip_param == 'name' ? '' : 'My Name'
    fill_in 'Username', with: skip_param == 'user_name' ? '' : 'new_user_name'
    fill_in 'Email', with: skip_param == 'email' ? '' : 'new@email.com'
  end

  def expect_update_profile_fails
    click_button 'Update'
    user.reload # capture update
    expect(page).to have_content 'Edit Profile'
  end

  def expect_update_profile_succeeds
    click_button 'Update'
    user.reload # capture update
    expect_profile_path
  end

  def expect_email_change_to_send_confirmation_instructions
    email = ActionMailer::Base.deliveries.last
    expect(email.to).to eq [new_email_user_params]
    user.reload
    expect_email_to_have_confirmation_path(email)
  end

  def expect_email_to_have_confirmation_path(email)
    expect(email.body.raw_source).to have_link('Confirm my account', href: expect_user_confirmation_path)
  end

  # test showing `http://example.com`
  # TODO: could figure it out, but this quick and dirty fix works for now
  def expect_user_confirmation_path
    'http://localhost:3000' + user_confirmation_path({ confirmation_token: user.confirmation_token })
  end

  def expect_email_change_success_message(email = user.email)
    expect(page).to have_css('.flash-success', text: confirm_email_change_message(email))
  end

  def confirm_email_change_message(email)
    "A confirmation email has been sent to #{email}. Click the link in the email to confirm the email address change Change this."
  end

  def expect_confirmation_succeeds
    expect(user.reload.confirmed?).to be_truthy
  end

  def expect_login_success
    fill_in 'Login', with: user.email
    fill_in 'Password', with: user.password
    click_button 'Log in'
    expect_root_path
  end

end
