class BuildCloud::VPC

    include ::BuildCloud::Component

    @@objects = []

    def self.get_id_by_name( name )

        vpc = self.search( :name => name ).first

        unless vpc
            raise "Couldn't get a VPC object for #{name} - is it defined?"
        end

        vpc_fog = vpc.read

        unless vpc_fog
            raise "Couldn't get a VPC fog object for #{name} - is it created?"
        end

        vpc_fog.id

    end

    def initialize ( fog_interfaces, log, options = {} )

        @compute = fog_interfaces[:compute]
        @log     = log
        @options = options

        @log.debug( options.inspect )

        required_options(:cidr_block)

    end

    def create
        
        return if exists?

        @log.info( "Creating new VPC for #{@options[:cidr_block]}" )

        vpc = @compute.vpcs.new( @options )
        vpc.save

        @log.debug( vpc.inspect )

        @compute.modify_vpc_attribute( vpc.id, { 'EnableDnsHostnames.Value' => true } )

    end

    def read
        @compute.vpcs.select { |v| v.cidr_block == @options[:cidr_block] }.first
    end

    alias_method :fog_object, :read

    def delete

        return unless exists?

        @log.info( "Deleting VPC for #{@options[:cidr_block]}" )

        fog_object.destroy

    end

    def [](key)
        @options[key]
    end

end
