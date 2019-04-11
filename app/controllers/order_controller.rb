require 'order_service.rb'

class OrderController < ApplicationController

    $result_values = []
    $selected_measure = []
    def requested_orders
       
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

  
    def result_entrly
        @identifier = params[:identifier]
        res = OrderService.get_tests_with_no_results(@identifier)
        
        @data = false
        if res != false
            @data = res
        end
        $selected_measure = []
        render :layout => false
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
        
        s = OrderService.print_tracking_number(params[:tracking_number],session[:user][2].to_s[0,1] + " " + session[:user][3],session[:patient],params[:priority], session[:selected_tests])
        send_data(s,
                  :type=>"application/label; charset=utf-8",
                  :stream=> false,
                  :filename=>"#{params[:tracking_number]}-#{rand(10000)}.lbl",
                  :disposition => "inline")
        
    end     

    def re_print_tracking_number
        tracking_number = params[:tracking_number]

        s = OrderService.re_print_tracking_number(tracking_number,session[:user][2].to_s[0,1] + " " + session[:user][3])
        send_data(s,
                  :type=>"application/label; charset=utf-8",
                  :stream=> false,
                  :filename=>"#{params[:tracking_number]}-#{rand(10000)}.lbl",
                  :disposition => "inline")
        
    end
    
    def pull_requested_orders
        npid = params[:identifier]
        res = OrderService.retrieve_requested_orders(npid)
        d = ""
        data = {
            :national_id    => npid,
            :name           => session[:patient][1].to_s + " " + session[:patient][2].to_s,
            :dob            => session[:patient][3],
            :gender         => session[:patient][4],
            :address        => "",
            :tests          => res[0]
        }
        
        render json: data 
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

    def enter_result_value
        @test_name = params[:test_name]
        @tracking_number = params[:tracking_number]
        @identifier = params[:identifier]
        
        
        res = OrderService.query_test_measures(@test_name)
        if res != false
            @data = res
            $selected_measure.each do |r|
                @data.delete(r)
            end
        end
    
    end

    def edit_result
        @measure_name = params[:measure_name]
        @identifier = params[:identifier]
        @rst_value = params[:result]
        counter = 0
        @tracking_number = params[:tracking_number]
        @test_name = params[:test_name]       
        $result_values.each do |r|            
            measure = r[2].keys[0]        
            if measure == @measure_name                    
                $result_values.delete_at(counter)               
            end
            counter = counter + 1
        end
    end

    def save_edited_result
        @measure_name = params[:measure_name]
        @result_value = params[:result][:result_value]
        @test_name = params[:test_name]
        @tracking_number = params[:tracking_number]
        @identifier = params[:identifier]

        values = {}
        values[@measure_name] = @result_value
        $result_values.push([@tracking_number,@test_name,values])
       
        redirect_to "/order/test_result_entry_confirmation?option=edit"+ "&identifier=" + @identifier +"&tracking_number=" + @tracking_number + "&test_name=" + @test_name + "&result_value=" + @result_value + "&measure_name=" + @measure_name
    end

    def test_result_entry_confirmation
        if params[:option] == 'edit'

            @measure_name = params[:measure_name]
            @result_value = params[:result_value]
            @tracking_number = params[:tracking_number]
            @test_name = params[:test_name]
            @identifier = params[:identifier]

            values = {}
            values[@measure_name] = @result_value
            $selected_measure.push(@measure_name)
            $result_values.push([@tracking_number,@test_name,values])
        else
            @measure_name = params[:measure]
            @result_value = params[:result][:result_value]
            @tracking_number = params[:tracking_number]
            @test_name = params[:test_name]
            @identifier = params[:identifier]

            values = {}
            values[@measure_name] = @result_value
            $selected_measure.push(@measure_name)
            $result_values.push([@tracking_number,@test_name,values])
        end
     
        render :layout => false
    end



    def save_result
        #results = params[:data].to_unsafe_h   
        #tracking_number = params[:tracking_number]
        #test_name = params[:test_name]   
        #test_name = test_name.gsub("AND","&")
               
        who_updated = {
                    'id_number': '',
                    'phone_number': '',
                    'first_name': '',
                    'last_name': ''
        }
        $result_values.each do |r|
            res = OrderService.save_results(r[0],r[1],r[2],who_updated)
        end
        $selected_measure = []
        $result_values = []
        render plain: true and return
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
        session['selected_tests'] =  tests
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

        print_url = "/order/print_tracking_number?tracking_number=#{tracking_number}&priority=#{priority}"
        print_and_redirect(print_url, "/order/check?identifier=#{identifier}")
    end
    
    def check
        

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
