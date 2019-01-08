module OrderService
   
    def self.retrieve_requested_orders(npid)
        
        configs = YAML.load_file "#{Rails.root}/config/nlims_service.yml"
        host = configs['host']
        prefix = configs['prefix']
        port = configs['port']
        protocol = configs['protocol']
       
        _token = File.read("#{Rails.root}/tmp/token")
        tests  = []     
        headers = {
            content_type: "application/json",
            token: _token
        }

        url = "#{protocol}://#{host}:#{port}#{prefix}query_requested_order_by_npid/#{npid}"
        res = JSON.parse(RestClient.get(url,headers))
        
        if res['error'] == false
            tests = res['data']['orders']
        end 
       
        return [tests]
    end

    def self.update_order_confirmation(tracking_number,specimen_type,target_lab)
        configs = YAML.load_file "#{Rails.root}/config/nlims_service.yml"
        host = configs['host']
        prefix = configs['prefix']
        port = configs['port']
        protocol = configs['protocol']

        prefix = prefix.gsub("v1","v2")
        
        _token = File.read("#{Rails.root}/tmp/token")

        data = {
            :tracking_number => tracking_number,
            :specimen_type => specimen_type,
            :target_lab => target_lab
        }

        headers = {
            content_type: 'application/json',
            token: _token
        }

        url = "#{protocol}://#{host}:#{port}#{prefix}confirm_order_request"
        res = JSON.parse(RestClient.post(url,data,headers))
        return res
    end

    def self.update_order_status(tracking_number)
        configs = YAML.load_file "#{Rails.root}/config/nlims_service.yml"
        host = configs['host']
        prefix = configs['prefix']
        port = configs['port']
        protocol = configs['protocol']
        reprint = [false, tracking_number]

        _token = File.read("#{Rails.root}/tmp/token")

        data = {
            :tracking_number => tracking_number,
            :status => "specimen_collected",
            :who_updated => {
                'id_number': '1',
                'phone_number': '2939393',
                'first_name': 'gibo',
                'last_name': 'malolo'
            }
        }

        headers = {
            content_type: 'application/json',
            token: _token
        }

        url = "#{protocol}://#{host}:#{port}#{prefix}update_order"
        res = JSON.parse(RestClient.post(url,data,headers))
   
        if res['error'] == false
            status =  [res['message'],tracking_number] 
            reprint = [true,tracking_number]
        end    

        return [status,reprint]
    end

    def self.print_tracking_number(tracking_number,collector)
        require 'auto12epl'

        data = OrderService.retrieve_patient_info(tracking_number,collector)
        
        auto = Auto12Epl.new
        s =  auto.generate_epl(data[0].to_s, data[1].to_s, data[2].to_s, data[3].to_s, data[4], data[5].to_s,
                               data[6].to_s, data[7], data[8].to_s, data[9].to_s,
                               data[10], data[11].to_s, data[12])
        return s
    end


    def self.retrieve_patient_info(tracking_number,collector)
        configs = YAML.load_file "#{Rails.root}/config/nlims_service.yml"
        host = configs['host']
        prefix = configs['prefix']
        port = configs['port']
        protocol = configs['protocol']

        _token = File.read("#{Rails.root}/tmp/token")

        headers = {
            content_type: 'application/json',
            token: _token
        }

        url = "#{protocol}://#{host}:#{port}#{prefix}query_order_by_tracking_number/#{tracking_number}"
      
        res = JSON.parse(RestClient.get(url,headers))

        if res['error'] == false
            patient = res['data']['other']['patient']
            other = res['data']['other']
            tests = res['data']['tests']
            tname = []
            tests.each do |key, value|
                tname.push(key)
            end

            tnam = tname.join(",")        
            middle_initial = patient['middle_name'].strip.scan(/\s\w+\s/).first.strip[0 .. 2] rescue ""
            dob = patient['dob'].to_date.strftime("%d-%b-%Y") rescue '-'               
            age = age(dob, other['date_created']) rescue "-"
            gender = patient['gender']
            col_datetime = other['date_created'].to_datetime.strftime("%d-%b-%Y %H:%M")
            col_by = collector #other['collector']['name']
            stat_el = other['priority'].downcase.to_s
            formatted_acc_num = tracking_number
            numerical_acc_num = tracking_number
            pat_first_name = patient['name'].split(" ")[0]
            pat_last_name = patient['name'].split(" ")[1]            

            return [pat_first_name,pat_last_name,middle_initial,patient['id'],dob,age,gender,col_datetime,col_by,tnam,stat_el,formatted_acc_num,numerical_acc_num]

        end
    end


    def self.retrieve_test_catelog
        configs = YAML.load_file "#{Rails.root}/config/nlims_service.yml"
        host = configs['host']
        prefix = configs['prefix']
        port = configs['port']
        protocol = configs['protocol']

        _token = File.read("#{Rails.root}/tmp/token")
        headers = {
            content_type: 'application/json',
            token: _token
        }

        url = "#{protocol}://#{host}:#{port}#{prefix}retrieve_test_Catelog"
        res = JSON.parse(RestClient.get(url,headers))

        if res['error'] == false
            return res['data']
        else
            return false
        end
    end

    def self.retrieve_target_labs
        configs = YAML.load_file "#{Rails.root}/config/nlims_service.yml"
        host = configs['host']
        prefix = configs['prefix']
        port = configs['port']
        protocol = configs['protocol']
        _token = File.read("#{Rails.root}/tmp/token")

        headers = {
            content_type: 'application/json',
            token: _token
        }

        url = "#{protocol}://#{host}:#{port}#{prefix}retrieve_target_labs"
        res = JSON.parse(RestClient.get(url,headers))

        if res['error'] == false
            return res['data']
        else
            return false
        end
    end

    def self.save_order(order_location,specimen_type,tests,priority,target_lab,requesting_clinician,session,patient,identifier)
        
        settings = YAML.load_file "#{Rails.root}/config/application.yml"
        configs = YAML.load_file "#{Rails.root}/config/emr_service.yml"
        configs = YAML.load_file "#{Rails.root}/config/nlims_service.yml"

        host = configs['host']
        prefix = configs['prefix']
        port = configs['port']
        protocol = configs['protocol']
        
        _token = File.read("#{Rails.root}/tmp/token")
       # headers = {
       #     content_type: 'application/json',
       #     Authorization: session[3]
       # }

        #data = {
        #        "specimen_type": specimen_type,
        #       "test_types": tests,
        #        "encounter_id": 6713247,
        #        "reason": priority,
        #       "target_lab": target_lab,
        #        "requesting_clinician": requesting_clinician
        #    }

        
                headers = {
                    content_type: 'application/json',
                    token: _token
                }

                json = {
                        :district => settings['district'],
                        :health_facility_name => settings['facility_name'],
                        :first_name=> patient[1],
                        :last_name=>  patient[2],
                        :middle_name=> '',
                        :date_of_birth=>  patient[3],
                        :gender=> patient[4],
                        :national_patient_id=>  identifier,
                        :phone_number=> "",
                        :reason_for_test=> (tests.include?("EID") ? 'HIV Exposed Infant' : 'Routine'),
                        :who_order_test_last_name=> session[2],
                        :who_order_test_first_name=> session[1],
                        :who_order_test_phone_number=> '',
                        :who_order_test_id=> session[0],
                        :order_location=> order_location,
                        :sample_type=> specimen_type,
                        :date_sample_drawn=> Date.today.strftime("%Y%m%d%H%M%S"),
                        :tests=> tests,
                        :sample_status => 'specimen_collected',
                        :sample_priority=> priority || 'Routine',
                        :target_lab=> target_lab,            
                        :art_start_date => (art_start_date rescue nil),            
                        :date_received => Date.today.strftime("%Y%m%d%H%M%S"),
                        :requesting_clinician => requesting_clinician        
                }       
                    
                url = "#{protocol}://#{host}:#{port}#{prefix}create_order"
                res = JSON.parse(RestClient.post(url,json,headers))            
       
        #url = "#{protocol}://#{host}:#{port}#{prefix}programs/1/lab_tests/orders"
        #res = JSON.parse(RestClient.post(url,data,headers))
        
        return [true, res['data']['tracking_number']]
        #return [true, res['lims_order']['tracking_number']] if !res['lims_order'].blank? 
        #return [false,''] if res['error'] == true

    end

    def self.retrieve_order_location
        configs = YAML.load_file "#{Rails.root}/config/nlims_service.yml"
        host = configs['host']
        prefix = configs['prefix']
        port = configs['port']
        protocol = configs['protocol']

        _token = File.read("#{Rails.root}/tmp/token")

        headers = {
            content_type: 'application/json',
            token: _token
        }

        url = "#{protocol}://#{host}:#{port}#{prefix}retrieve_order_location"
        res = JSON.parse(RestClient.get(url,headers))

        if res['error'] == false
            return res['data']
        else
            return false
        end
    end

end

