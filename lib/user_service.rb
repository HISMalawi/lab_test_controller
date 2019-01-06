module UserService

    def self.authenticate(usernam,passwor)
        configs = YAML.load_file "#{Rails.root}/config/emr_service.yml"
        settings = YAML.load_file "#{Rails.root}/config/application.yml"

        host = configs['host']
        prefix = configs['prefix']
        port = configs['port']
        protocol = configs['protocol']

        url = "#{protocol}://#{host}:#{port}#{prefix}auth/login"
        begin
            res = JSON.parse(RestClient.post(url,{username: usernam,password: passwor}, content_type: 'application/json'))
            return [true,res]
        rescue StandardError => e
            return [false,e]
        end        

    end

end
