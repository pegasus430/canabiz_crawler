class Leafbuyer < ActiveJob::Base
    include SuckerPunch::Job
    
    def perform(state_abbreviation)
        @state_abbreviation = state_abbreviation
        @state = State.where(abbreviation: @state_abbreviation.upcase).first
        @dispensaries = Dispensary.where(state_id: @state.id)
        scrapeLeafBuyer()
    end
    
    def scrapeLeafBuyer()
        require "json"
        require 'open-uri'
        
        output = IO.popen(["python", "#{Rails.root}/app/scrapers/leafbuyer_disp_scraper.py", @state_abbreviation])
        contents = JSON.parse(output.read)
        
        puts 'HERE ARE THE CONTENTS: '
        puts contents
        
        if contents[@state_abbreviation] != nil
            parseDeals(contents[state_name]) 
        end
    end
    
    def parseDeals(state_deals)
        
        # deal fields
        # t.integer  "dispensary_id"
        # t.string   "name"
        # t.decimal  "discount"
        # t.string   "deal_type"
        # t.boolean  "top_deal"
        # t.integer  "min_age"
        # t.string   "image"
       
        state_deals.each do |deal|
           
            deal = Deal.new(
                :name => deal['deal_name'], 
				:state_id => @state.id,
				:remote_image_url => deal['image_url'],
				:min_age => deal['minimum_age'],
				:top_deal => deal['is_top_deal']
            )   
            
            #deal price / quantity and such
            if deal['deal_price']['percentageOff'].present? && eal['deal_price']['percentageOff'] > 0
                
                deal.deal_type = 'discount'
                deal.discount = deal['deal_price']['percentageOff']
            end
           
            #see if we have a dispensary where name matches
            existing_dispensaries = @dispensaries.select { |disp| vendor.name.casecmp(deal['name']) == 0 }
            if existing_dispensaries.size > 0
                deal.dispensary_id = existing_dispensaries[0].id   
            end
            
            #save deal
            unless deal.save
        		puts "deal Save Error: #{deal.errors.messages}"
        	end
            
       end #end of deal loop
        
    end
end