class ForceParamsEncoding
    def initialize(app)
        @app = app
    end
    
    def call(env)
        @request = Rack::Request.new(env)
        params = @request.params
        params.each { |k, v|  params[k] = v.force_encoding("ISO-8859-1").encode("UTF-8") }
        @app.call(env)
    end
end