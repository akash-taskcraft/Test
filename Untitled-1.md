require 'rails_helper'

describe 'account_block/accounts' do
    let!(:brand) { FactoryBot.create(:brand) }
    let!(:account) { FactoryBot.create(:account, brand_id: brand.id) }
    let!(:role) { FactoryBot.create(:role, name: 'albertbauer', permission: 'viewer') }
    before do
        auth_token = BuilderJsonWebToken::JsonWebToken.encode(account.id)
        @headers = {
            "token" => auth_token,
            "Content-Type" => "application/json"
        }
    end

    describe 'post #create' do
      let(:request_params) do
        {
          data: {
            type: "email_account",
            attributes: {
            email: "jane_doe77@example.com",
            first_name: "jane",
            last_name: "doe",
            password: "Jane@Doe123",
            company_name: 'Albert Bauer',
            role_id: role.id
           }
        }
      }
      end

      let(:observed_account_attributes_response_json) do
        {
          "type" => request_params[:data][:type],
          "first_name" => request_params[:data][:first_name],
          "last_name" => request_params[:data][:last_name],
          "email" => request_params[:data][:email],
          "password" => request_params[:data][:password],
          "brand_id" => request_params[:data][:brand_id],
        }
      end

      it 'returns successful response' do
        post '/account_block/accounts', params: request_params.to_json, headers: @headers
        expect(response).to have_http_status(200)
      end

      it 'returns sample project for newly created user' do
        get '/bx_block_project_portfolio/projects', headers: @headers
        response_json = JSON.parse(response.body)
        expect(response_json).not_to be_nil
      end

      it 'returns sample task for newly created user' do
        get '/bx_block_project_portfolio/tasks', headers: @headers
        response_json = JSON.parse(response.body)
        expect(response_json).not_to be_nil
      end

      it 'returns error when user already existed' do
        role = FactoryBot.create(:role, name:"albertbauer", permission: nil)
        AccountBlock::Account.create!(email: "jane_doe77@example.com", brand_id: brand.id, password: "ABCGD@1234", role_id: role.id)
        post '/account_block/accounts', params: request_params.to_json, headers: @headers
        response_json = JSON.parse(response.body)
        expect(response_json['errors']).to eq([{"account" => 'Registration not allowed'}])
      end

    context 'Valid company name given on signup' do
      let(:request_params) do
        {
          data: {
            type: "email_account",
            attributes: {
            email: "jane_doe77@example.com",
            first_name: "jane",
            last_name: "doe",
            password: "Jane@Doe123",
            company_name: 'Albert Bauer',
            role_id: role.id
           }
        }
      }
      end

      it 'returns success when company name given is valid' do
        post '/account_block/accounts', params: request_params.to_json, headers: @headers
        expect(response).to have_http_status(200)
      end
     end

     context 'Valid email_domain given on signup' do
      let(:request_params) do
        {
          data: {
            type: "email_account",
            attributes: {
            email: "jane_doe77@example.com",
            first_name: "jane",
            last_name: "doe",
            password: "Jane@Doe123",
            company_name: 'Albert Bauer',
            role_id: role.id
           }
        }
      }
      end

      it 'returns success when email_domain given is valid' do
        post '/account_block/accounts', params: request_params.to_json, headers: @headers
        expect(response.status).to eq 200
      end
    end

    context 'Invalid email_domain given on signup' do
      let(:request_params) do
        {
          data: {
            type: "email_account",
            attributes: {
            email: "jane_doe77@example2.com",
            first_name: "jane",
            last_name: "doe",
            password: "Jane@Doe123",
            company_name: 'Albert Bauer',
            role_id: role.id
           }
        }
      }
      end

      it 'returns error when email_domain given is invalid' do
        post '/account_block/accounts', params: request_params.to_json, headers: @headers
        response_json = JSON.parse(response.body)
        expect(response_json['errors']).to eq([{"email"=>"Email Domain not found"}])
      end
     end
    end

    describe 'GET #show' do
      let(:request_params) do
        {
            id: account.id
        }
      end

      let(:observed_response_json) do
        {
          "data" =>  {
            "id" => account.id.to_s,
            "type" => "account",
            "attributes" => {
                "activated" => account.activated,
                "country_code" => account.country_code,
                "email" => account.email,
                "first_name" => account.first_name,
                "full_phone_number" => account.full_phone_number,
                "last_name" => account.last_name,
                "brand_id" => account.brand_id,
                "phone_number" => account.phone_number,
                "username" => account.username,
                "timezone" => account.timezone,
                "language" => account.language,
                "start_of_week" => account.start_of_week,
                "created_at" => account.created_at&.strftime('%d %b %Y %-l:%M %p'),
                "updated_at" => account.updated_at&.strftime('%d %b %Y %-l:%M %p'),
                "device_id" => account.device_id,
                "unique_auth_id" => account.unique_auth_id,
                "photo_blob_signed_id_url" => account.photo_blob_signed_id_url,
                "bio" => account.bio,
                "designation" => account.designation,
                "is_blocked" => account.is_blocked,
                "clock_setting"=> account.clock_setting,
                "sign_in_count"=> account.sign_in_count,
                "hubspot_token"=> account.hubspot_token,
                "is_suspended"=> account.is_suspended,
                "is_albertbauer_user"=> account.is_albertbauer_user?,
                "role"=>{
                  "data"=>{
                    "id"=> account.role.id.to_s,
                    "type"=>"role",
                    "attributes"=>{
                      "id"=> account.role.id,
                      "name"=> account.role.name,
                      "permission"=> account.role.permission,
                      "created_at"=> account.role.created_at&.strftime('%d %b %Y %-l:%M %p'),
                      "updated_at"=> account.role.updated_at&.strftime('%d %b %Y %-l:%M %p')
                    }
                  }
                }
              }
            }
          }
      end

      context 'it returns the single account' do
        it 'returns the single account' do
          get '/account_block/accounts/' + account.id.to_s, params: request_params.to_json, headers: @headers

          expect(response.status).to eq 200
        end
      end

      it 'returns successful response' do
          get '/account_block/accounts/' + account.id.to_s, params: request_params.to_json, headers: @headers
          expect(response).to have_http_status(200)
      end

      it 'returns successful response data' do
          get '/account_block/accounts/' + account.id.to_s, params: request_params.to_json, headers: @headers
          response_json = JSON.parse(response.body)
          expect(response_json['data']).to eq(observed_response_json['data'])
      end

      it 'indicates that the account with the id is not found' do
        get '/account_block/accounts/' + 100.to_s, params: request_params.to_json, headers: @headers
        expect(response.status).to eq 422
      end

      it 'returns error for missing token' do
        get '/account_block/accounts/' + account.id.to_s, params: request_params.to_json
        expect(response).to have_http_status(400)
      end
    end

    describe 'PUT #update' do
      let!(:brand) { FactoryBot.create(:brand) }
      let!(:new_account) { FactoryBot.create(:account, email: "randy_orton_new@example.com", brand_id: brand.id, role_id: role.id) }

       let(:request_params) do
          {
            data: {
              email: "randy_orton_new@example.com",
              first_name: "randy",
              last_name: "orton",
              username: "randy_orton_new1",
              activated: true,
              company_name: 'Albert Bauer',
              timezone: "America/Tijuana"
            }
          }
        end

        context 'update the account with valid data' do
          let(:account_data) do
            {
              :email => request_params[:data][:email],
              :first_name => request_params[:data][:first_name],
              :last_name=> request_params[:data][:last_name],
              :username => request_params[:data][:username],
              :activated => request_params[:data][:activated],
              :company_name => request_params[:data][:company_name],
              :timezone => request_params[:data][:timezone]
            }
          end

          it 'updates the account' do
            put '/account_block/accounts/' + new_account.id.to_s, params: account_data.to_json, headers: @headers
            expect(response.status).to eq 200
          end

          it 'do not update the account when timezone is incorrect' do
            request_params[:data][:timezone] = 'American'
            put '/account_block/accounts/' + new_account.id.to_s, params: account_data.to_json, headers: @headers
            response_json = JSON.parse(response.body)
            expect(response_json['errors']).to eq([{"account"=>{"timezone"=>["Timezone is incorrect"]}}])
          end
        end

        let(:observed_response_json) do
          {
            "data" =>  {
              "id" => account.id.to_s,
              "type" => "account",
              "attributes" => {
                  "activated" => account.activated,
                  "country_code" => account.country_code,
                  "email" => account.email,
                  "first_name" => account.first_name,
                  "bio" => account.bio,
                  "designation" => account.designation,
                  "full_phone_number" => account.full_phone_number,
                  "last_name" => account.last_name,
                  "brand_id" => account.brand_id,
                  "phone_number" => account.phone_number,
                  "username" => account.username,
                  "timezone" => account.timezone,
                  "language" => account.language,
                  "start_of_week" => account.start_of_week,
                  "created_at" => account.created_at&.strftime('%d %b %Y %-l:%M %p'),
                  "updated_at" => account.updated_at&.strftime('%d %b %Y %-l:%M %p'),
                  "device_id" => account.device_id,
                  "unique_auth_id" => account.unique_auth_id
                 }
              }
          }
      end

      context 'On given invalid company name' do
          let(:request_params) do
              {
                email: "randy_orton_new@example.com",
                first_name: "randy",
                last_name: "orton",
                username: "randy_orton_new1",
                activated: true,
                company_name: 'Albert'
              }

          end

          it 'do not update the account when company name is invalid' do
            put '/account_block/accounts/' + new_account.id.to_s, params: request_params.to_json, headers: @headers
            response_json = JSON.parse(response.body)
            expect(response_json['errors']).to eq([{"account"=>{"company_name"=>["Company name is incorrect"]}}])
          end
      end

      context 'On given designation' do
          let(:request_params) do
              {
                designation: "Developer",
              }
          end

          let(:observed_account_attributes_response_json) do
            {
              "designation" => request_params[:designation]
            }
          end

          it 'updates the designation column' do
            put '/account_block/accounts/' + new_account.id.to_s, params: request_params.to_json, headers: @headers
            response_json = JSON.parse(response.body)
            expect(response_json["data"]["attributes"]["designation"]).to eq(observed_account_attributes_response_json["designation"])
          end
      end

      context 'On given blank last_name, first_name, email' do
          let(:request_params) do
              {
                email: "randy_orton_new@example.com",
                first_name: "randy",
                last_name: "orton",
                username: "randy_orton_new1",
                activated: true,
                company_name: 'Albert Bauer'
              }

          end

          it 'do not update the account when email is blank' do
            request_params[:email] = ''
            put '/account_block/accounts/' + new_account.id.to_s, params: request_params.to_json, headers: @headers
            response_json = JSON.parse(response.body)
            expect(response_json['errors']).to eq([{"account"=>
                                                   {"email"=> ["Email must be present", "User work email does not match with the company domain"]}}])
          end

          it 'do not update the account when first_name is blank' do
            request_params[:first_name] = ''
            put '/account_block/accounts/' + new_account.id.to_s, params: request_params.to_json, headers: @headers
            response_json = JSON.parse(response.body)
            expect(response_json['errors']).to eq([{"account"=>{"first_name"=>["First Name must be present"]}}])
          end

          it 'do not update the account when last_name is blank' do
            request_params[:last_name] = ''
            put '/account_block/accounts/' + new_account.id.to_s, params: request_params.to_json, headers: @headers
            response_json = JSON.parse(response.body)
            expect(response_json['errors']).to eq([{"account"=>{"last_name"=>["Last Name must be present"]}}])
          end
      end

      context 'when email is not given' do
          let(:request_params) do
              {
                first_name: "randy",
                last_name: "orton",
                username: "randy_orton_new1",
                company_name: 'Albert Bauer'
              }

          end

          it 'should update the account' do
            put '/account_block/accounts/' + new_account.id.to_s, params: request_params.to_json, headers: @headers
            response_json = JSON.parse(response.body)
            expect(response.status).to eq 200
          end
      end

      context 'On given valid company name' do
          let(:request_params) do
              {
                email: "randy_orton_new@example.com",
                first_name: "randy",
                last_name: "orton",
                username: "randy_orton_new1",
                activated: true,
                company_name: 'Albert Bauer'
              }

          end

          it 'updates the account when company name is valid' do
            put '/account_block/accounts/' + new_account.id.to_s, params: request_params.to_json, headers: @headers
            expect(response.status).to eq 200
          end

          context 'On given invalid email domain of company' do
              let(:request_params) do
                  {
                    email: "randy_orton_new@example2.com",
                    first_name: "randy",
                    last_name: "orton",
                    username: "randy_orton_new1",
                    activated: true,
                    company_name: 'Albert Bauer'
                  }

              end

              it 'do not update the account when email domain is invalid' do
                put '/account_block/accounts/' + new_account.id.to_s, params: request_params.to_json, headers: @headers
                response_json = JSON.parse(response.body)
                expect(response_json['errors']).to eq([{"account"=>{"email"=>["User work email does not match with the company domain"]}}])
              end
          end

          context 'On company name key not present' do
              let(:request_params) do
                  {
                    email: "randy_orton_new@example.com",
                    first_name: "randy",
                    last_name: "orton",
                    username: "randy_orton_new1",
                    activated: true,
                  }

              end

              it 'updates the account even when company name key is not present' do
                put '/account_block/accounts/' + new_account.id.to_s, params: request_params.to_json, headers: @headers
                expect(response.status).to eq 200
              end
            end

          context 'On given valid email domain of company' do
            let(:request_params) do
                {
                  email: "randy_orton_new@example.com",
                  first_name: "randy",
                  last_name: "orton",
                  username: "randy_orton_new1",
                  activated: true,
                  company_name: 'Albert Bauer'
                }

            end

            it 'updates the account when email domain is valid' do
              put '/account_block/accounts/' + new_account.id.to_s, params: request_params.to_json, headers: @headers
              expect(response.status).to eq 200
            end
          end

          context 'De-activate the user' do
            let!(:brand_new) { FactoryBot.create(:brand, name: "Albert Bauer 2", email_domain: "albertbauer.com") }
            let!(:test_account) { FactoryBot.create(:account, email: "test_account@albertbauer.com", brand_id: brand_new.id, activated: true) }

            let(:request_params) do
              {
                activated: false,
              }
            end

            it 'de-activates the user' do
              put '/account_block/accounts/' + test_account.id.to_s, params: request_params.to_json, headers: @headers
              response_json = JSON.parse(response.body)
              expect(response_json["data"]["attributes"]["activated"]).to eq(false)
            end
          end

          context 'Activate the user' do
            let!(:brand_new) { FactoryBot.create(:brand, name: "Albert Bauer 2", email_domain: "albertbauer.com") }
            let!(:test_account) { FactoryBot.create(:account, email: "test_account@albertbauer.com", brand_id: brand_new.id, activated: false) }

            let(:request_params) do
              {
                activated: true,
              }
            end

            it 'activates the user' do
              put '/account_block/accounts/' + test_account.id.to_s, params: request_params.to_json, headers: @headers
              response_json = JSON.parse(response.body)
              expect(response_json["data"]["attributes"]["activated"]).to eq(true)
            end
          end

          context 'Permission to block user' do
            let!(:brand_new) { FactoryBot.create(:brand, name: "Albert Bauer 2", email_domain: "albertbauer.com") }
            let!(:test_account) { FactoryBot.create(:account, email: "test_account@albertbauer.com", brand_id: brand_new.id, is_blocked: false) }

            let(:request_params) do
              {
                is_blocked: true,
              }
            end

            it 'allows super admin to block user' do
                admin_account = FactoryBot.create(:super_admin, brand_id: brand_new.id)

                auth_token = BuilderJsonWebToken::JsonWebToken.encode(admin_account.id)
                @headers = {
                    "token" => auth_token,
                    "Content-Type" => "application/json"
                }
                put '/account_block/accounts/' + test_account.id.to_s, params: request_params.to_json, headers: @headers
                response_json = JSON.parse(response.body)
                expect(response_json['data']['id']).not_to be_nil
                expect(response_json['data']['type']).to eq('account')
                expect(response_json["data"]["attributes"]["is_blocked"]).to eq(true)
            end

            it 'allows ab_brand_manager to block user' do
                ab_brand_manager_account = FactoryBot.create(:ab_brand_manager, brand_id: brand_new.id)

                auth_token = BuilderJsonWebToken::JsonWebToken.encode(ab_brand_manager_account.id)
                @headers = {
                    "token" => auth_token,
                    "Content-Type" => "application/json"
                }
                put '/account_block/accounts/' + test_account.id.to_s, params: request_params.to_json, headers: @headers
                response_json = JSON.parse(response.body)
                expect(response_json['data']['id']).not_to be_nil
                expect(response_json['data']['type']).to eq('account')
                expect(response_json["data"]["attributes"]["is_blocked"]).to eq(true)
            end

            it 'allows client_brand_manager to block his own brand user' do
                client_brand_manager_account = FactoryBot.create(:client_brand_manager, brand_id: brand_new.id)

                auth_token = BuilderJsonWebToken::JsonWebToken.encode(client_brand_manager_account.id)
                @headers = {
                    "token" => auth_token,
                    "Content-Type" => "application/json"
                }
                put '/account_block/accounts/' + test_account.id.to_s, params: request_params.to_json, headers: @headers
                response_json = JSON.parse(response.body)
                expect(response_json['data']['id']).not_to be_nil
                expect(response_json['data']['type']).to eq('account')
                expect(response_json["data"]["attributes"]["is_blocked"]).to eq(true)
            end

            it 'does not allow ab_editor to block user' do
                account2 = FactoryBot.create(:ab_editor, brand_id: brand_new.id)

                auth_token = BuilderJsonWebToken::JsonWebToken.encode(account2.id)
                @headers = {
                    "token" => auth_token,
                    "Content-Type" => "application/json"
                }
                put '/account_block/accounts/' + test_account.id.to_s, params: request_params.to_json, headers: @headers
                response_json = JSON.parse(response.body)
                expect(response_json['errors']).to eq([
                    {"account"=>{"role"=>["You are not authorized to perform this action."]}}
                  ])
            end

            it 'does not allow ab_viewer to block user' do
                account2 = FactoryBot.create(:ab_viewer, brand_id: brand_new.id)

                auth_token = BuilderJsonWebToken::JsonWebToken.encode(account2.id)
                @headers = {
                    "token" => auth_token,
                    "Content-Type" => "application/json"
                }
                put '/account_block/accounts/' + test_account.id.to_s, params: request_params.to_json, headers: @headers
                response_json = JSON.parse(response.body)
                expect(response_json['errors']).to eq([
                    {"account"=>{"role"=>["You are not authorized to perform this action."]}}
                  ])
            end

            it 'does not allow client_approver to block user' do
                account2 = FactoryBot.create(:client_approver, brand_id: brand_new.id)

                auth_token = BuilderJsonWebToken::JsonWebToken.encode(account2.id)
                @headers = {
                    "token" => auth_token,
                    "Content-Type" => "application/json"
                }
                put '/account_block/accounts/' + test_account.id.to_s, params: request_params.to_json, headers: @headers
                response_json = JSON.parse(response.body)
                expect(response_json['errors']).to eq([
                    {"account"=>{"role"=>["You are not authorized to perform this action."]}}
                  ])
            end

            it 'does not allow client_viewer to block user' do
                account2 = FactoryBot.create(:client_viewer, brand_id: brand_new.id)

                auth_token = BuilderJsonWebToken::JsonWebToken.encode(account2.id)
                @headers = {
                    "token" => auth_token,
                    "Content-Type" => "application/json"
                }
                put '/account_block/accounts/' + test_account.id.to_s, params: request_params.to_json, headers: @headers
                response_json = JSON.parse(response.body)
                expect(response_json['errors']).to eq([
                    {"account"=>{"role"=>["You are not authorized to perform this action."]}}
                  ])
            end
          end

          context 'Permission to un-block user' do
            let!(:brand_new) { FactoryBot.create(:brand, name: "Albert Bauer 2", email_domain: "albertbauer.com") }
            let!(:test_account) { FactoryBot.create(:account, email: "test_account@albertbauer.com", brand_id: brand_new.id, is_blocked: true) }

            let(:request_params) do
              {
                is_blocked: false,
              }
            end

            it 'allows only super admin to un-block user' do
                admin_account = FactoryBot.create(:super_admin, brand_id: brand_new.id)

                auth_token = BuilderJsonWebToken::JsonWebToken.encode(admin_account.id)
                @headers = {
                    "token" => auth_token,
                    "Content-Type" => "application/json"
                }
                put '/account_block/accounts/' + test_account.id.to_s, params: request_params.to_json, headers: @headers
                response_json = JSON.parse(response.body)
                expect(response_json['data']['id']).not_to be_nil
                expect(response_json['data']['type']).to eq('account')
                expect(response_json["data"]["attributes"]["is_blocked"]).to eq(false)
            end

            it 'does not allow ab_editor to un-block user' do
                account2 = FactoryBot.create(:ab_editor, brand_id: brand_new.id)

                auth_token = BuilderJsonWebToken::JsonWebToken.encode(account2.id)
                @headers = {
                    "token" => auth_token,
                    "Content-Type" => "application/json"
                }
                put '/account_block/accounts/' + test_account.id.to_s, params: request_params.to_json, headers: @headers
                response_json = JSON.parse(response.body)
                expect(response_json['errors']).to eq([
                    {"account"=>{"role"=>["You are not authorized to perform this action."]}}
                  ])
            end

            it 'does not allow ab_viewer to un-block user' do
                account2 = FactoryBot.create(:ab_viewer, brand_id: brand_new.id)

                auth_token = BuilderJsonWebToken::JsonWebToken.encode(account2.id)
                @headers = {
                    "token" => auth_token,
                    "Content-Type" => "application/json"
                }
                put '/account_block/accounts/' + test_account.id.to_s, params: request_params.to_json, headers: @headers
                response_json = JSON.parse(response.body)
                expect(response_json['errors']).to eq([
                    {"account"=>{"role"=>["You are not authorized to perform this action."]}}
                  ])
            end

            it 'does not allow client_approver to un-block user' do
                account2 = FactoryBot.create(:client_approver, brand_id: brand_new.id)

                auth_token = BuilderJsonWebToken::JsonWebToken.encode(account2.id)
                @headers = {
                    "token" => auth_token,
                    "Content-Type" => "application/json"
                }
                put '/account_block/accounts/' + test_account.id.to_s, params: request_params.to_json, headers: @headers
                response_json = JSON.parse(response.body)
                expect(response_json['errors']).to eq([
                    {"account"=>{"role"=>["You are not authorized to perform this action."]}}
                  ])
            end

            it 'does not allow client_viewer to un-block user' do
                account2 = FactoryBot.create(:client_viewer, brand_id: brand_new.id)

                auth_token = BuilderJsonWebToken::JsonWebToken.encode(account2.id)
                @headers = {
                    "token" => auth_token,
                    "Content-Type" => "application/json"
                }
                put '/account_block/accounts/' + test_account.id.to_s, params: request_params.to_json, headers: @headers
                response_json = JSON.parse(response.body)
                expect(response_json['errors']).to eq([
                    {"account"=>{"role"=>["You are not authorized to perform this action."]}}
                  ])
            end
          end

      # it 'returns successful response' do
      #     put '/account_block/accounts/' + account.id.to_s, params: request_params.to_json, headers: @headers
      #     expect(response).to have_http_status(200)
      # end

      # it 'returns successful response data' do
      #     put '/account_block/accounts/' + account.id.to_s, params: request_params.to_json, headers: @headers
      #     response_json = JSON.parse(response.body)
      #     expect(response_json['data']).to eq(observed_response_json['data'])
      # end

      context 'remove account photo' do
        let(:request_params) do
            {
              photo_blob_signed_id: nil
            }
        end

        it 'should update photo_blob_signed_id as nil' do
          put '/account_block/accounts/' + new_account.id.to_s, params: request_params.to_json, headers: @headers
          expect(response.status).to eq 200
        end

        it 'returns successful response data' do
          put '/account_block/accounts/' + new_account.id.to_s, params: request_params.to_json, headers: @headers
          response_json = JSON.parse(response.body)
          expect(response_json["data"]["attributes"]["photo_blob_signed_id_url"]).to eq(observed_response_json["photo_blob_signed_id_url"])
        end
      end

      it 'returns error for missing token' do
        put '/account_block/accounts/' + new_account.id.to_s, params: request_params.to_json
        expect(response).to have_http_status(400)
      end


    end

    describe 'DELETE' do
     let!(:new_account) { FactoryBot.create(:account, email: "randy_orton_new@example.com", brand_id: brand.id, role_id: role.id) }

     it 'returns successful response' do
       delete '/account_block/accounts/' + new_account.id.to_s, headers: @headers
       expect(response).to have_http_status(200)
     end

     it 'update the deleted user email' do
       delete '/account_block/accounts/' + new_account.id.to_s, headers: @headers
       expect(response).to have_http_status(200)
       response_json = JSON.parse(response.body)
       id = response_json["id"].to_i
       deleted_account = AccountBlock::Account.with_deleted.find(id)
       deleted_account_email = deleted_account.email.include?("__#{id}__deleted")
       expect(deleted_account_email).to eq(true)
     end

     it 'returns response for a missing record' do
       delete '/account_block/accounts/' + 100000.to_s, headers: @headers
       expect(response.status).to eq 422
     end

     it 'returns error for missing token' do
       delete '/account_block/accounts/' + new_account.id.to_s
       expect(response).to have_http_status(400)
     end
    end

    describe 'Index' do

      let(:item_count) { 21 }

      it 'returns successful response' do
        get '/account_block/accounts/', headers: @headers
        expect(response).to have_http_status(200)
      end

      context 'page 1 with default page = 1 and per_page = 10' do
        it 'returns correct number of accounts ' do
          item_count.times do |i|
            FactoryBot.create(:account, email: "randy_orton2#{i}@example.com", brand_id: brand.id)
          end
          get '/account_block/accounts/', headers: @headers
          response_json = JSON.parse(response.body)
          expect(response_json['accounts']['data'].count).to eq(10)
        end

        it 'returns correct collection of accounts' do
          item_count.times do |i|
            FactoryBot.create(:account, email: "randy_orton2#{i}@example.com", brand_id: brand.id)
          end
          get '/account_block/accounts/', headers: @headers
          response_json = JSON.parse(response.body)
          first_id = AccountBlock::Account.first.id
          expect(response_json['accounts']['data'][0]['id']).to eq(first_id.to_s)
          expect(response_json['accounts']['data'][9]['id']).to eq((first_id + 9).to_s)
        end

        it 'returns next_page condition for accounts' do
          item_count.times do |i|
            FactoryBot.create(:account, email: "randy_orton2#{i}@example.com", brand_id: brand.id)
          end
          get '/account_block/accounts/', headers: @headers
          response_json = JSON.parse(response.body)
          expect(response_json['next_page']).to be_truthy
        end

        it 'returns total_count for accounts' do
          item_count.times do |i|
            FactoryBot.create(:account, email: "randy_orton2#{i}@example.com", brand_id: brand.id)
          end
          get '/account_block/accounts/', headers: @headers
          response_json = JSON.parse(response.body)
          expect(response_json['total_count']).to eq(item_count + 2)
        end

        it 'returns total_pages for accounts' do
          item_count.times do |i|
            FactoryBot.create(:account, email: "randy_orton2#{i}@example.com", brand_id: brand.id)
          end
          get '/account_block/accounts/', headers: @headers
          response_json = JSON.parse(response.body)
          expect(response_json['total_pages']).to eq(3)
        end
      end

      context 'page 2 and default per_page = 10' do
        let(:index_params) do
          {
              page: 2
          }
        end

        it 'returns correct number of accounts' do
          item_count.times do |i|
            FactoryBot.create(:account, email: "randy_orton2#{i}@example.com", brand_id: brand.id)
          end
          get '/account_block/accounts/', params: index_params, headers: @headers
          response_json = JSON.parse(response.body)
          expect(response_json['accounts']['data'].count).to eq(10)
        end

        it 'returns correct collection of accounts' do
          item_count.times do |i|
            FactoryBot.create(:account, email: "randy_orton2#{i}@example.com", brand_id: brand.id)
          end
          get '/account_block/accounts/', params: index_params, headers: @headers
          response_json = JSON.parse(response.body)
          first_id = AccountBlock::Account.first.id
          expect(response_json['accounts']['data'][0]['id']).to eq((first_id + 10).to_s)
          expect(response_json['accounts']['data'][9]['id']).to eq((first_id + 19).to_s)
        end

        it 'returns next_page condition for accounts' do
          item_count.times do |i|
            FactoryBot.create(:account, email: "randy_orton2#{i}@example.com", brand_id: brand.id)
          end
          get '/account_block/accounts/', params: index_params, headers: @headers
          response_json = JSON.parse(response.body)
          expect(response_json['next_page']).to be_truthy
        end

        it 'returns no total_count' do
          item_count.times do |i|
            FactoryBot.create(:account, email: "randy_orton2#{i}@example.com", brand_id: brand.id)
          end
          get '/account_block/accounts/', params: index_params, headers: @headers
          response_json = JSON.parse(response.body)
          expect(response_json['total_count']).to be_nil
        end

        it 'returns no total_pages' do
          item_count.times do |i|
            FactoryBot.create(:account, email: "randy_orton2#{i}@example.com", brand_id: brand.id)
          end
          get '/account_block/accounts/', params: index_params, headers: @headers
          response_json = JSON.parse(response.body)
          expect(response_json['total_pages']).to be_nil
        end
      end

      context 'last page and default per_page = 10' do
        let(:index_params) do
          {
              page: 3
          }
        end

        it 'returns correct number of accounts' do
          item_count.times do |i|
            FactoryBot.create(:account, email: "randy_orton2#{i}@example.com", brand_id: brand.id)
          end
          get '/account_block/accounts/', params: index_params, headers: @headers
          response_json = JSON.parse(response.body)
          expect(response_json['accounts']['data'].count).to eq(3)
        end

        it 'returns correct collection of accounts' do
          item_count.times do |i|
            FactoryBot.create(:account, email: "randy_orton2#{i}@example.com", brand_id: brand.id)
          end
          get '/account_block/accounts/', params: index_params, headers: @headers
          response_json = JSON.parse(response.body)
          first_id = AccountBlock::Account.first.id
          expect(response_json['accounts']['data'][0]['id']).to eq((first_id + 20).to_s)
        end

        it 'returns next_page condition for accounts' do
          item_count.times do |i|
            FactoryBot.create(:account, email: "randy_orton2#{i}@example.com", brand_id: brand.id)
          end
          get '/account_block/accounts/', params: index_params, headers: @headers
          response_json = JSON.parse(response.body)
          expect(response_json['next_page']).to be_falsy
        end

        it 'returns no total_count' do
          item_count.times do |i|
            FactoryBot.create(:account, email: "randy_orton2#{i}@example.com", brand_id: brand.id)
          end
          get '/account_block/accounts/', params: index_params, headers: @headers
          response_json = JSON.parse(response.body)
          expect(response_json['total_count']).to be_nil
        end

        it 'returns no total_pages' do
          item_count.times do |i|
            FactoryBot.create(:account, email: "randy_orton2#{i}@example.com", brand_id: brand.id)
          end
          get '/account_block/accounts/', params: index_params, headers: @headers
          response_json = JSON.parse(response.body)
          expect(response_json['total_pages']).to be_nil
        end
      end

      context 'page = 1 and per_page = 5' do
        let(:index_params) do
          {
              page: 1,
              per_page: 5
          }
        end

        it 'returns correct number of accounts' do
          item_count.times do |i|
            FactoryBot.create(:account, email: "randy_orton2#{i}@example.com", brand_id: brand.id)
          end
          get '/account_block/accounts/', params: index_params, headers: @headers
          response_json = JSON.parse(response.body)
          expect(response_json['accounts']['data'].count).to eq(5)
        end

        it 'returns correct collection of accounts' do
          item_count.times do |i|
            FactoryBot.create(:account, email: "randy_orton2#{i}@example.com", brand_id: brand.id)
          end
          get '/account_block/accounts/', params: index_params, headers: @headers
          response_json = JSON.parse(response.body)
          first_id = AccountBlock::Account.first.id
          expect(response_json['accounts']['data'][0]['id']).to eq(first_id.to_s)
          expect(response_json['accounts']['data'][4]['id']).to eq((first_id + 4).to_s)
        end

        it 'returns next_page condition for accounts' do
          item_count.times do |i|
            FactoryBot.create(:account, email: "randy_orton2#{i}@example.com", brand_id: brand.id)
          end
          get '/account_block/accounts/', params: index_params, headers: @headers
          response_json = JSON.parse(response.body)
          expect(response_json['next_page']).to be_truthy
        end

        it 'returns total_count for accounts' do
          item_count.times do |i|
            FactoryBot.create(:account, email: "randy_orton2#{i}@example.com", brand_id: brand.id)
          end
          get '/account_block/accounts/', params: index_params, headers: @headers
          response_json = JSON.parse(response.body)
          expect(response_json['total_count']).to eq(item_count + 2)
        end

        it 'returns total_pages for accounts' do
          item_count.times do |i|
            FactoryBot.create(:account, email: "randy_orton2#{i}@example.com", brand_id: brand.id)
          end
          get '/account_block/accounts/', params: index_params, headers: @headers
          response_json = JSON.parse(response.body)
          expect(response_json['total_pages']).to eq(5)
        end
      end

      context 'Permissions for seeing accounts' do
        let!(:brand_2) { FactoryBot.create(:brand, name: "BrandAB", email_domain: "BrandAB.com") }
        let!(:account) { FactoryBot.create(:account, first_name: 'John', email: 'johncenaucsm@wwe.com', brand_id: brand.id) }
        let!(:account_2) { FactoryBot.create(:account, first_name: 'Kevin', email: 'kevinstunner@wwe.com', brand_id: brand.id) }
        let!(:account_3) { FactoryBot.create(:account, first_name: 'Kevin A', email: 'kevinstunner2@wwe.com', brand_id: brand_2.id) }
        let!(:account_4) { FactoryBot.create(:account, first_name: 'Kevin B', email: 'kevinstunner3@wwe.com', brand_id: brand_2.id) }

        it 'shows all accounts when user is super_admin' do
          admin_account = FactoryBot.create(:super_admin, brand_id: brand.id)

          auth_token = BuilderJsonWebToken::JsonWebToken.encode(admin_account.id)
          @headers = {
              "token" => auth_token,
              "Content-Type" => "application/json"
          }
          get '/account_block/accounts', headers: @headers
          response_json = JSON.parse(response.body)
          expect(response_json['accounts']['data'].count).to eq(6)
        end

        it 'shows all accounts when user is ab_editor' do
          ab_account = FactoryBot.create(:ab_editor, brand_id: brand.id)

          auth_token = BuilderJsonWebToken::JsonWebToken.encode(ab_account.id)
          @headers = {
              "token" => auth_token,
              "Content-Type" => "application/json"
          }
          get '/account_block/accounts', headers: @headers
          response_json = JSON.parse(response.body)
          expect(response_json['accounts']['data'].count).to eq(6)
        end

        it 'shows all accounts when user is ab_viewer' do
          ab_account = FactoryBot.create(:ab_viewer, brand_id: brand.id)

          auth_token = BuilderJsonWebToken::JsonWebToken.encode(ab_account.id)
          @headers = {
              "token" => auth_token,
              "Content-Type" => "application/json"
          }
          get '/account_block/accounts', headers: @headers
          response_json = JSON.parse(response.body)
          expect(response_json['accounts']['data'].count).to eq(6)
        end

        it 'shows all accounts when user is ab_brand_manager' do
          ab_account = FactoryBot.create(:ab_brand_manager, brand_id: brand.id)

          auth_token = BuilderJsonWebToken::JsonWebToken.encode(ab_account.id)
          @headers = {
              "token" => auth_token,
              "Content-Type" => "application/json"
          }
          get '/account_block/accounts', headers: @headers
          response_json = JSON.parse(response.body)
          expect(response_json['accounts']['data'].count).to eq(6)
        end

        it 'shows only his/her brand accounts when user is client_brand_manager' do
          client_account = FactoryBot.create(:client_brand_manager, brand_id: brand_2.id)

          auth_token = BuilderJsonWebToken::JsonWebToken.encode(client_account.id)
          @headers = {
              "token" => auth_token,
              "Content-Type" => "application/json"
          }
          get '/account_block/accounts', headers: @headers
          response_json = JSON.parse(response.body)
          expect(response_json['accounts']['data'].count).to eq(3)
        end

        it 'shows only his/her brand accounts when user is client_approver' do
          client_account = FactoryBot.create(:client_approver, brand_id: brand_2.id)

          auth_token = BuilderJsonWebToken::JsonWebToken.encode(client_account.id)
          @headers = {
              "token" => auth_token,
              "Content-Type" => "application/json"
          }
          get '/account_block/accounts', headers: @headers
          response_json = JSON.parse(response.body)
          expect(response_json['accounts']['data'].count).to eq(3)
        end

        it 'shows only his/her brand accounts when user is client_viewer' do
          client_account = FactoryBot.create(:client_viewer, brand_id: brand_2.id)

          auth_token = BuilderJsonWebToken::JsonWebToken.encode(client_account.id)
          @headers = {
              "token" => auth_token,
              "Content-Type" => "application/json"
          }
          get '/account_block/accounts', headers: @headers
          response_json = JSON.parse(response.body)
          expect(response_json['accounts']['data'].count).to eq(3)
        end
      end

      context 'accounts for first_name scope' do
        let!(:account) { FactoryBot.create(:account, first_name: 'John', email: 'johncenaucsm@wwe.com', brand_id: brand.id) }
        let!(:account_2) { FactoryBot.create(:account, first_name: 'Kevin', email: 'kevinstunner@wwe.com', brand_id: brand.id) }

        it 'shows only one account when params contains first_name' do
          index_params = {
            "first_name" => 'John'
          }
          get '/account_block/accounts', params: index_params, headers: @headers
          response_json = JSON.parse(response.body)
          expect(response_json['accounts']['data'].count).to eq(1)
          expect(response_json['accounts']['data'][0]['attributes']['first_name']).to eq('John')
        end

        it 'shows account even if params contains first_name in uppercase' do
          index_params = {
            "first_name" => 'JOHN'
          }
          get '/account_block/accounts', params: index_params, headers: @headers
          response_json = JSON.parse(response.body)
          expect(response_json['accounts']['data'].count).to eq(1)
          expect(response_json['accounts']['data'][0]['attributes']['first_name']).to eq('John')
        end

        it 'shows all accounts when params contains no first_name' do
          get '/account_block/accounts', headers: @headers
          response_json = JSON.parse(response.body)
          expect(response_json['accounts']['data'].count).to eq(3)
          expect(response_json['accounts']['data'][0]['attributes']['first_name']).to eq('John')
          expect(response_json['accounts']['data'][2]['attributes']['first_name']).to eq('Kevin')
          expect(response_json['accounts']['data'][1]['attributes']['first_name']).to eq('Jane')
        end
      end

      context 'accounts for last_name scope' do
        let!(:account) { FactoryBot.create(:account, last_name: 'Cena', email: 'johncenaucsm2@wwe.com', brand_id: brand.id) }
        let!(:account_4) { FactoryBot.create(:account, last_name: 'Owens', email: 'kevinstunner2@wwe.com', brand_id: brand.id) }

        it 'shows only one account when params contains last_name' do
          index_params = {
            "last_name" => 'Owens'
          }
          get '/account_block/accounts', params: index_params, headers: @headers
          response_json = JSON.parse(response.body)
          expect(response_json['accounts']['data'].count).to eq(1)
          expect(response_json['accounts']['data'][0]['attributes']['last_name']).to eq('Owens')
        end

        it 'shows account even if params contains some characters of last_name in uppercase' do
          index_params = {
            "last_name" => 'OweNS'
          }
          get '/account_block/accounts', params: index_params, headers: @headers
          response_json = JSON.parse(response.body)
          expect(response_json['accounts']['data'].count).to eq(1)
          expect(response_json['accounts']['data'][0]['attributes']['last_name']).to eq('Owens')
        end

        it 'shows all accounts when params contains no last_name' do
          get '/account_block/accounts', headers: @headers
          response_json = JSON.parse(response.body)
          expect(response_json['accounts']['data'].count).to eq(3)
          expect(response_json['accounts']['data'][0]['attributes']['last_name']).to eq('Cena')
          expect(response_json['accounts']['data'][1]['attributes']['last_name']).to eq('Doe')
          expect(response_json['accounts']['data'][2]['attributes']['last_name']).to eq('Owens')
        end
      end

      context 'accounts for email scope' do
        let!(:account) { FactoryBot.create(:account, email: 'johncenaucsm3@wwe.com', brand_id: brand.id) }
        let!(:account_6) { FactoryBot.create(:account, email: 'kevinstunner3@wwe.com', brand_id: brand.id) }

        it 'shows only one account when params contains email' do
          index_params = {
            "email" => 'kevinstunner3@wwe.com'
          }
          get '/account_block/accounts', params: index_params, headers: @headers
          response_json = JSON.parse(response.body)
          expect(response_json['accounts']['data'].count).to eq(1)
          expect(response_json['accounts']['data'][0]['attributes']['email']).to eq(account_6.email)
        end

        it 'shows account even if params contains email in uppercase' do
          index_params = {
            "email" => 'KEVINSTUNNER3@WWE.COM'
          }
          get '/account_block/accounts', params: index_params, headers: @headers
          response_json = JSON.parse(response.body)
          expect(response_json['accounts']['data'].count).to eq(1)
          expect(response_json['accounts']['data'][0]['attributes']['email']).to eq(account_6.email)
        end

        it 'shows all accounts when params contains no email' do
          get '/account_block/accounts', headers: @headers
          response_json = JSON.parse(response.body)
          expect(response_json['accounts']['data'].count).to eq(3)
          expect(response_json['accounts']['data'][0]['attributes']['email']).to eq(account.email)
          expect(response_json['accounts']['data'][2]['attributes']['email']).to eq(account_6.email)
          expect(response_json['accounts']['data'][1]['attributes']['email']).to eq(new_account.email)
        end
      end

      context 'accounts for username scope' do
        let!(:account) { FactoryBot.create(:account, username: 'johncenaucsm3', email: 'johncenaucsm3@wwe.com', brand_id: brand.id) }
        let!(:account_7) { FactoryBot.create(:account, username: 'kevinstunner3', email: 'kevinstunner3@wwe.com', brand_id: brand.id) }

        it 'shows only one account when params contains username' do
          index_params = {
            "username" => 'kevinstunner3'
          }
          get '/account_block/accounts', params: index_params, headers: @headers
          response_json = JSON.parse(response.body)
          expect(response_json['accounts']['data'].count).to eq(1)
          expect(response_json['accounts']['data'][0]['attributes']['username']).to eq(account_7.username)
        end

        it 'shows account even if params contains username in uppercase' do
          index_params = {
            "username" => 'KEVINSTUNNER3'
          }
          get '/account_block/accounts', params: index_params, headers: @headers
          response_json = JSON.parse(response.body)
          expect(response_json['accounts']['data'].count).to eq(1)
          expect(response_json['accounts']['data'][0]['attributes']['username']).to eq(account_7.username)
        end

        it 'shows all accounts when params contains no username' do
          get '/account_block/accounts', headers: @headers
          response_json = JSON.parse(response.body)
          expect(response_json['accounts']['data'].count).to eq(3)
          expect(response_json['accounts']['data'][0]['attributes']['username']).to eq(account.username)
          expect(response_json['accounts']['data'][2]['attributes']['username']).to eq(account_7.username)
          expect(response_json['accounts']['data'][1]['attributes']['username']).to eq(new_account.username)
        end
      end

      context 'accounts for brand_id scope' do
        let!(:brand_2) { FactoryBot.create(:brand, name: 'WWE', email_domain: "wwe.com") }
        let!(:account) { FactoryBot.create(:account, email: 'johncenaucsm3@wwe.com', brand_id: brand.id) }
        let!(:account_8) { FactoryBot.create(:account, email: 'kevinstunner3@wwe.com', brand_id: brand_2.id) }

        it 'shows only one account when params contains brand_id' do
          index_params = {
            "brand_id" => brand.id
          }
          get '/account_block/accounts', params: index_params, headers: @headers
          response_json = JSON.parse(response.body)
          expect(response_json['accounts']['data'].count).to eq(2)
          expect(response_json['accounts']['data'][0]['attributes']['brand_id']).to eq(account.brand_id)
        end

        it 'shows all accounts when params contains no brand_id' do
          get '/account_block/accounts', headers: @headers
          response_json = JSON.parse(response.body)
          expect(response_json['accounts']['data'].count).to eq(3)
          expect(response_json['accounts']['data'][0]['attributes']['brand_id']).to eq(account.brand_id)
          expect(response_json['accounts']['data'][2]['attributes']['brand_id']).to eq(account_8.brand_id)
          expect(response_json['accounts']['data'][1]['attributes']['brand_id']).to eq(new_account.brand_id)
        end
      end

      context 'accounts for first_name, last_name and email all three in one scope' do
        let!(:brand_3) { FactoryBot.create(:brand, name: 'WWE NEW', email_domain: "wwenew.com") }
        let!(:account) { FactoryBot.create(:account, username: "johncenaucsm3", first_name: "John", last_name: "Cena", email: 'johncenaucsm3@wwe.com', brand_id: brand.id) }
        let!(:account_9) { FactoryBot.create(:account, first_name: "Kevin", last_name: "Owens", email: 'kevinstunner38@wwe.com', brand_id: brand_3.id) }

        it 'shows only one account when params contains first_name' do
          index_params = {
            "user" => "kevin"
          }
          get '/account_block/accounts', params: index_params, headers: @headers
          response_json = JSON.parse(response.body)
          expect(response_json['accounts']['data'].count).to eq(1)
          expect(response_json['accounts']['data'][0]['attributes']['first_name']).to eq(account_9.first_name)
        end

        it 'shows only one account when params contains last_name' do
          index_params = {
            "user" => "cena"
          }
          get '/account_block/accounts', params: index_params, headers: @headers
          response_json = JSON.parse(response.body)
          expect(response_json['accounts']['data'].count).to eq(1)
          expect(response_json['accounts']['data'][0]['attributes']['last_name']).to eq(account.last_name)
        end

        it 'shows only one account when params contains email' do
          index_params = {
            "user" => "johncenaucsm3@wwe.com"
          }
          get '/account_block/accounts', params: index_params, headers: @headers
          response_json = JSON.parse(response.body)
          expect(response_json['accounts']['data'].count).to eq(1)
          expect(response_json['accounts']['data'][0]['attributes']['email']).to eq(account.email)
        end

        it 'shows only one account when params contains username' do
          index_params = {
            "user" => "johncenaucsm3"
          }
          get '/account_block/accounts', params: index_params, headers: @headers
          response_json = JSON.parse(response.body)
          expect(response_json['accounts']['data'].count).to eq(1)
          expect(response_json['accounts']['data'][0]['attributes']['username']).to eq(account.username)
        end
      end

      context 'accounts for is_blocked scope' do
        let!(:account) { FactoryBot.create(:account, email: 'johncenaucsm3@wwe.com', brand_id: brand.id, is_blocked: true) }
        let!(:account_8) { FactoryBot.create(:account, email: 'kevinstunner3@wwe.com', brand_id: brand.id) }

        it 'shows only one account when params contains is_blocked => true scope' do
        auth_token = BuilderJsonWebToken::JsonWebToken.encode(account_8.id)
          @headers = {
              "token" => auth_token,
              "Content-Type" => "application/json"
          }
          index_params = {
            "is_blocked" => true
          }
          get '/account_block/accounts', params: index_params, headers: @headers
          response_json = JSON.parse(response.body)
          expect(response_json['accounts']['data'].count).to eq(1)
          expect(response_json['accounts']['data'][0]['attributes']['is_blocked']).to eq(account.is_blocked)
        end

        it 'shows all accounts when params contains is_blocked => false scope' do
          auth_token = BuilderJsonWebToken::JsonWebToken.encode(account_8.id)
          @headers = {
              "token" => auth_token,
              "Content-Type" => "application/json"
          }
          index_params = {
            "is_blocked" => false
          }
          get '/account_block/accounts', params: index_params, headers: @headers
          response_json = JSON.parse(response.body)
          expect(response_json['accounts']['data'].count).to eq(3)
          expect(response_json['accounts']['data'][0]['attributes']['is_blocked']).to eq(account.is_blocked)
          expect(response_json['accounts']['data'][1]['attributes']['is_blocked']).to eq(account_8.is_blocked)
          expect(response_json['accounts']['data'][1]['attributes']['is_blocked']).to eq(new_account.is_blocked)
        end
      end
    end
  end
end

