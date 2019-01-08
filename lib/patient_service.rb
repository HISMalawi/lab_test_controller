module PatientService


    def self.scan_patient(identifier,token)
        configs = YAML.load_file "#{Rails.root}/config/emr_service.yml"
        settings = YAML.load_file "#{Rails.root}/config/application.yml"

        host = configs['host']
        prefix = configs['prefix']
        port = configs['port']
        protocol = configs['protocol']

        url = "#{protocol}://#{host}:#{port}#{prefix}search/patients/by_npid?npid=#{identifier}"
        begin
            res = JSON.parse(RestClient.get(url,{content_type: 'application/json', Authorization: token}))
            if res.blank?
                return [false,[]]
            else
                return [true,res]
            end
        rescue StandardError => e
            return [false,e]            
        end
    end

end
