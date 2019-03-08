require 'patient_service'
class PatientController < ApplicationController

    def confirm
        identifier = params[:identifier]
        res = PatientService.scan_patient(identifier,session[:user][0])
  
        if res[0] == true
          
            if res[1].length == 1
                p_id = res[1][0]['patient_id']          
                f_name = res[1][0]['person']['names'][0]['given_name']
                s_name = res[1][0]['person']['names'][0]['family_name']
                birthdate = res[1][0]['person']['birthdate']
                gender = res[1][0]['person']['gender']
                session[:patient] = [p_id,f_name,s_name,birthdate,gender]
                redirect_to '/order/requested_orders?identifier=' + identifier 
            else
                @patients = res[1][0]
                p_id = res[1][0]['patient_id']          
                f_name = res[1][0]['person']['names'][0]['given_name']
                s_name = res[1][0]['person']['names'][0]['family_name']
                birthdate = res[1][0]['person']['birthdate']
                gender = res[1][0]['person']['gender']
                session[:patient] = [p_id,f_name,s_name,birthdate,gender]
                redirect_to '/order/requested_orders?identifier=' + identifier 
            end            
        
        else
            redirect_to '/user/index?patient_not_found=yes'
           
        end
    end

    def search_by_name

    end

    def search_by_name_results
        first_name = params[:first_name]
        last_name = params[:last_name]
        gender = params[:gender]
        @found_patients = []
        identifier = ""
        res = PatientService.search_patient_by_name(first_name,last_name,gender,session[:user][0])
       
        if res[0] == true
            res[1].each do |data|
             
                person_id = data['person_id']
                gender = data['gender']
                birthdate = data['birthdate']
                first_name = data['names'][0]['given_name']
                last_name = data['names'][0]['family_name']
                city_village = data['addresses'][0]['city_village']
                state_province = data['addresses'][0]['state_province']
                r = PatientService.search_patient_identifiers_by_patient_id(person_id,session[:user][0])
                
                if r[0] == true
                    r[1][0]['identifier']
                    if r[1][0]['type']['patient_identifier_type_id'] == 3
                        identifier = r[1][0]['identifier']
                    end
                else

                end
                @found_patients.push([person_id,first_name,last_name,gender,birthdate,city_village,state_province,identifier])               
            end                     
        else
            
        end       
        render :layout => false
    end

    def set_patient_in_session
        p_id = params[:id]
        f_name = params[:first_name]
        s_name = params[:last_name]
        birthdate = params[:birthdata]
        gender = params[:gender]
        patient_id = params[:patient_id]
        session[:patient] = [p_id,f_name,s_name,birthdate,gender,patient_id]
        render plain: true and return
    end

    def search_patient
        search_option = params[:search_option]
        if search_option == "by_name"
            first_name = params[:name][:given_name]
            last_name = params[:name][:family_name]
            gender = params[:gender]
            redirect_to "/patient/search_by_name_results?first_name=#{first_name}&last_name=#{last_name}&gender=#{gender}"
        else
            identifier = params[:identifier]
            res = PatientService.scan_patient(identifier,session[:user][0])
    
            if res[0] == true
            
                if res[1].length == 0
                    p_id = res[1][0]['patient_id']            
                    f_name = res[1][0]['person']['names'][0]['given_name']
                    s_name = res[1][0]['person']['names'][0]['family_name']
                    birthdate = res[1][0]['person']['birthdate']
                    gender = res[1][0]['person']['gender']
                    session[:patient] = [p_id,f_name,s_name,birthdate,gender]
                    #redirect_to '/order/requested_orders?identifier=' + identifier         
                end
                @patients = res[1]
                render plain: @patients.to_json  and return
            else
                #redirect_to '/user/index?patient_not_found=yes'
                render plain: false and return
            end
        end
    end

    def select
        raise params.inspect
    end

end
