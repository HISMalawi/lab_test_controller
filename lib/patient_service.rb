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

    def self.search_patient_identifiers_by_patient_id(patient_id,token)
        configs = YAML.load_file "#{Rails.root}/config/emr_service.yml"
        settings = YAML.load_file "#{Rails.root}/config/application.yml"

        host = configs['host']
        prefix = configs['prefix']
        port = configs['port']
        protocol = configs['protocol']

        url = "#{protocol}://#{host}:#{port}#{prefix}patient_identifiers?patient_id=#{patient_id}"
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

    def self.search_patient_by_name(first_name,last_name,gender,token)
        configs = YAML.load_file "#{Rails.root}/config/emr_service.yml"
        settings = YAML.load_file "#{Rails.root}/config/application.yml"

        host = configs['host']
        prefix = configs['prefix']
        port = configs['port']
        protocol = configs['protocol']

        url = "#{protocol}://#{host}:#{port}#{prefix}search/people?given_name=#{first_name}&family_name=#{last_name}&gender=#{gender}&page_size=20&page=0"
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
