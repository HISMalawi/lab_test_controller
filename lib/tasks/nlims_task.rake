
namespace :nlims do
  desc "TODO"
  task authenticate: :environment do
  	config = YAML.load_file("#{Rails.root}/config/nlims_service.yml")
	nlims_controller_ip = "#{config['protocol']}://#{config['host']}:#{config['port']}"
  	nlims_url = nlims_controller_ip + "/api/v1/authenticate/" +  config['nlims_default_username'] + "/" + config['nlims_default_password']
   

  	res =  JSON.parse(RestClient.get(nlims_url, :content_type => 'application/json'))

    if res['error'] == false
      token = res['data']['token']
      File.open("#{Rails.root}/tmp/token",'w') { |f|
        f.write(token)
      }

      puts res['message'] + "!  create account now"
    else
      puts res
    end

  end
  


  desc "TODO"
  task create_account: :environment do
    settings = YAML.load_file("#{Rails.root}/config/application.yml")
    config = YAML.load_file("#{Rails.root}/config/nlims_service.yml")
    token = File.read("#{Rails.root}/tmp/token")
    nlims_controller_ip = "#{config['protocol']}://#{config['host']}:#{config['port']}"
    nlims_url = nlims_controller_ip + "/api/v1/create_user"
    
    account_details = {
            "partner": config['partner'],
            "app_name": config['app_name'],
            "location": settings['district'],
            "password": config['nlims_custome_password'],
            "username": config['nlims_custome_username']
    }   
    headers = {
      content_type:  'application/json',
      token: token
    }
    res =  JSON.parse(RestClient.post(nlims_url, account_details,headers))

        if res['error'] == false
            File.open("#{Rails.root}/tmp/token",'w') {|f|
              f.write(res['data']['token'])
            }
            puts res['message'] +"! can now access nlims resources"

        else

          puts res['message']  
        end 


  end

end
