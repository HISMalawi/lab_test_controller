require 'order_service.rb'

class OrderController < ApplicationController


    def requested_orders
        npid = params[:identifier]
        res = OrderService.retrieve_requested_orders(npid)
       
            @national_id    = npid
            @name           = session[:patient][1].to_s + " " + session[:patient][2].to_s
            @dob            = session[:patient][3]
            @gender         = session[:patient][4]
            @address        = ""
            @tests          = res[0]
           
            render :layout => false
    end

    def confirm_order
        @tracking_number = params[:tracking_number]
        @identifier = params[:identifier]
        test_name = params[:test_name]
        cat = OrderService.retrieve_test_catelog
        if cat != false
            @specimen_types = cat[test_name]
        end
    end

    def update_order_confirmation
        tracking_number = params[:tracking_number]
        identifier = params[:identifier]
        specimen_type = params[:specimen_type]
        target_lab = params[:target_labs]

        st = OrderService.update_order_confirmation(tracking_number,specimen_type,target_lab)
        print_url = "/order/print_tracking_number?tracking_number=#{tracking_number}"
        print_and_redirect(print_url, "/order/requested_orders?identifier=#{identifier}")
    end

    def update_order_status
        tracking_number = params[:tracking_number]
        res = OrderService.update_order_status(tracking_number)
        status = res[0] 
        @reprint = res[1]

        render plain: status and return
    end


    def print_tracking_number
        require 'auto12epl'
       
        s = OrderService.print_tracking_number(params[:tracking_number],session[:user][2].to_s[0,1] + " " + session[:user][3])
        send_data(s,
                  :type=>"application/label; charset=utf-8",
                  :stream=> false,
                  :filename=>"#{params[:tracking_number]}-#{rand(10000)}.lbl",
                  :disposition => "inline")
        
    end     
    

    def pr(tr)
        require 'auto12epl'
       
        s = OrderService.print_tracking_number(r,session[:user][2].to_s[0,1] + " " + session[:user][3])
        send_data(s,
                  :type=>"application/label; charset=utf-8",
                  :stream=> false,
                  :filename=>"#{params[:tracking_number]}-#{rand(10000)}.lbl",
                  :disposition => "inline")
    end

    def order_test
        
        cat = OrderService.retrieve_test_catelog
        specimen_type = []
        if cat != false           
            cat.values.each  do |t|
                t.each do |r|
                    specimen_type.push(r) if !specimen_type.include?(r)
                end
            end            
        end

        @specimen_types = specimen_type.sort
    end

    def save_order
        
        add_test = params[:add_test] if !params[:add_test].blank?
        identifier = params[:identifier]
        order_location = params[:order_location]
        specimen_type = params[:specimen_type]
        tests = params[:test_types]
        target_lab = params[:target_labs]
        priority = params[:priority]
        requesting_clinician = params[:order]['requesting_clinician']
        tracking_number = ''
        t_n = []
        if add_test == 'No'
            tests.each do |t|
                t_n.push(t)
                status = OrderService.save_order(order_location,specimen_type,t_n,priority,target_lab,requesting_clinician,[session[:user][1],session[:user][2],session[:user][3],session[:user][0]],session[:patient],identifier)
                if status[0] == true
                    tracking_number = status[1]
                end
                t_n = []
            end
        else
            status = OrderService.save_order(order_location,specimen_type,tests,priority,target_lab,requesting_clinician,[session[:user][1],session[:user][2],session[:user][3],session[:user][0]],session[:patient],identifier)
                if status[0] == true
                    tracking_number = status[1]
                end
        end

        print_url = "/order/print_tracking_number?tracking_number=#{tracking_number}"
        print_and_redirect(print_url, "/order/requested_orders?identifier=#{identifier}")
    end

    def select_test_types
        specimen_type_ = params[:specimen_type]
        cat = OrderService.retrieve_test_catelog
      
        tests = []
        if cat != false  
            cat.each do |k,v|      
                puts k
                if v.include?(specimen_type_)
                    tests.push(k) if !tests.include?(k)
                end
            end       
        end
        render plain: "<li>" + tests.uniq.map{|n| n } .join("</li><li>") + "</li>"
    end 

    def get_target_labs 
        search_string = params[:search_string].downcase
        res = OrderService.retrieve_target_labs.sort()        
        if search_string.length > 0
            res = res.map(&:downcase)
            res = res.grep(/#{search_string}/)
            res = res.map(&:titleize)
        end        
        render plain: "<li>" + res.uniq.map{|n| n } .join("</li><li>") + "</li>" and return
    end

    def get_order_location
        res = OrderService.retrieve_order_location.sort()
        render plain: "<li>" + res.uniq.map{|n| n } .join("</li><li>") + "</li>" and return
    end
end
