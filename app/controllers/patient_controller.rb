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
            end
            @patients = res[1]
        else
            redirect_to '/user/index?patient_not_found=yes'
        end
    end

end
