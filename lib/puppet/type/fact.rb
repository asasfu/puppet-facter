Puppet::Type.newtype(:fact) do
  @doc = "Create a custom fact as text file under /etc/facter/facts.d
      fact { 'environment':
        content => 'production',
        target  => 'env',
      }"


  #ensurable
  #ensurable do
  #  defaultvalues
  #  defaultto :present
  #end

  ensurable do
    defaultvalues
    defaultto do
      if @resource.managed?
        :present
      else
        nil
      end
    end
  end

#  newproperty(:ensure) do
#    desc "Ensure the resource"
#    defaultto do
#      if @resource.managed?
#        :present
#      else
#        nil
#      end
#    end
#  end


  newparam(:name, :namevar => true) do
    desc "The fact name"
    isnamevar

    validate do |value|
      fail("Name cannot be empty or whitespace") if munge(value).match(/^\s*$/)
      fail("Name cannot contain a path, only alphanumeric including underscores and dashes") if munge(value).match(/\//)
    end



    #munge do |discard|
    #  puts "DISCARD #{discard}"
    #  puts "Orig params: #{@resource.original_parameters}"
    #  if discard.include?('/etc/facter/facts.d/')
    #    puts "Munge: returning what you gave me #{discard}"
    #    discard
    #  else
    #    puts "Munge: adding path before return /etc/facter/facts.d/#{discard}.yaml"
    #    "/etc/facter/facts.d/#{discard}.yaml"
    #  end
    #end
    #working#munge do |discard|
    #working#  puts "DISCARD #{discard}"
    #working#  puts "Orig params: #{@resource.original_parameters}"
    #working#  if discard.include?('/etc/facter/facts.d/')
    #working#    puts "Munge: returning what you gave me #{discard}"
    #working#    discard
    #working#  else
    #working#    puts "Munge: adding path before return /etc/facter/facts.d/#{discard}.yaml"
    #working#    "/etc/facter/facts.d/#{discard}.yaml"
    #working#  end
    #working#end
  end

  newproperty(:content, :array_matching => :all) do
  #newproperty(:content) do
    desc "The content of the fact"
    #def insync?(is)
    #  puts "INSYNC start"
    #  puts "INSYNC parameters: #{@parameters}"
    #  puts "IS: #{is}"
    #  puts "@IS: #{@is}"
    #  puts "IS.inspect: #{is.inspect}"
    #  puts "IS.class: #{is.class}"
    #  puts "SHOULD: #{should}"
    #  puts "@SHOULD: #{@should}"
    #  insync = true

    #  if property = @parameters[:ensure]
    #    puts "INSYNC ensure"
    #    unless is.include? property
    #      raise Puppet::DevError,
    #        "The is value is not in the is array for '#{property.name}'"
    #    end
    #    ensureis = is[property]
    #    if property.safe_insync?(ensureis) and property.should == :absent
    #      return true
    #    end
    #  end
    #  puts "INSYNC ensure done"

    #  properties.each { |property|
    #    unless is.include? property
    #      raise Puppet::DevError,
    #        "The is value is not in the is array for '#{property.name}'"
    #    end

    #    propis = is[property]
    #    unless property.safe_insync?(propis)
    #      property.debug("Not in sync: #{propis.inspect} vs #{property.should.inspect}")
    #      insync = false
    #    #else
    #    #    property.debug("In sync")
    #    end
    #  }

    #  #self.debug("#{self} sync status is #{insync}")
    #  puts "IS: #{is}"
    #  puts "@IS: #{@is}"
    #  puts "IS.inspect: #{is.inspect}"
    #  puts "IS.class: #{is.class}"
    #  puts "SHOULD: #{should}"
    #  puts "@SHOULD: #{@should}"
    #  insync
    #end

    #defaultto 'true'
    validate do |value|
      if value.is_a?(Hash)
        fail("Content cannot be empty or whitespace") if value.empty?
      else
        fail("Content cannot be empty or whitespace") if munge(value).match(/^\s*$/)
      end
    end

    munge do |value|
#      puts "Munging content: #{value}"
      if value.is_a?(Array)
        if value[1].nil?
          if value[0].is_a?(Hash)
#            puts "HASH!"
            prov_result = value[0]
#            puts prov_result
            return prov_result
          else
#            puts "ONLY A STRING or SINGLE ARRAY VALUE"
            prov_result = value[0].to_s
            return prov_result
          end
        else
#          puts "FULL ON ARRAY"
          prov_result = value
          return prov_result
        end
      elsif value.is_a?(Hash)
#        puts "HASHmunge: #{value}"
        return value
      else
#        puts "Didn't match any other munge: #{value}"
        value_hash = is_yaml_to_hash(value)
        value_hash = value if value_hash.nil? || value_hash.empty? 
#        puts "Since it didn't match, I tested yaml_to_hash: #{value_hash}"
        return value_hash
      end
    end

    #def should_to_s(s)
    #  puts "Should_to_s #{s}\n"
    #  "#{s[0]}"
    #end
    
    def is_yaml_to_hash(is)
#      puts "is_yaml_to_hash: #{is}"
      begin
        YAML.load(is).values[0]
      rescue
        is
      end
    end


    #def is_to_s(is)
    #  #puts "is_to_s #{is}"
    #  is_yaml_to_hash(is)
    #  #puts "Is_to_s #{s}\n"
    #  #result = s
    #  #begin
    #  #  result = YAML.load(s).values[0]
    #  #rescue
    #  #end
    #  #puts "Is_to_s end #{result}\n\n"
    #  #"#{result}"
    #end

    def insync?(is)
#      puts "Insync is: #{is}"
      result = is_yaml_to_hash(is)
      #if result.is_a?(Array)
      #  puts "Insync is array: #{result}"
      #  super(result)
      #else
      #  puts "Insync is not array: #{[result]}"
      #  super([result])
      #end
      #
#      result.is_a?(Array) ? (puts "Insync is array: #{result}") : (puts "Insync is not array: #{[result]}")
#      puts "Insync should: #{should}"
      result.is_a?(Array) ? super(result) : super([result])
      #
      #result.is_a?(Array) ? (puts "Insync is array: #{result}") : (puts "Insync is not array: #{[result]}")
      #puts "Insync should: #{should}"
      #result.is_a?(Array) ? (result == should) : ([result] == should)
      #super(is_yaml_to_hash(is))
      #super([result])
      #new_is = is
      #begin
      #  new_is = YAML.load(is).values[0]
      #rescue
      #end
      #puts "Insync end #{new_is}\n\n"
      #"#{new_is}"
    end

#   def insync?(is)
#     self.devfail "#{self.class.name}'s should is not array" unless @should.is_a?(Array)
# 
#     # an empty array is analogous to no should values
#     return true if @should.empty?
# 
#     # Look for a matching value, either for all the @should values, or any of
#     # them, depending on the configuration of this property.
#     if match_all? then
#       # Emulate Array#== using our own comparison function.
#       # A non-array was not equal to an array, which @should always is.
#       return false unless is.is_a? Array
# 
#       # If they were different lengths, they are not equal.
#       return false unless is.length == @should.length
# 
#       # Finally, are all the elements equal?  In order to preserve the
#       # behaviour of previous 2.7.x releases, we need to impose some fun rules
#       # on "equality" here.
#       #
#       # Specifically, we need to implement *this* comparison: the two arrays
#       # are identical if the is values are == the should values, or if the is
#       # values are == the should values, stringified.
#       #
#       # This does mean that property equality is not commutative, and will not
#       # work unless the `is` value is carefully arranged to match the should.
#       return (is == @should or is == @should.map(&:to_s))
# 
#       # When we stop being idiots about this, and actually have meaningful
#       # semantics, this version is the thing we actually want to do.
#       #
#       # return is.zip(@should).all? {|a, b| property_matches?(a, b) }
#     else
#       return @should.any? {|want| property_matches?(is, want) }
#     end
#   end


  end

#  newproperty(:target) do
#    desc "Target file to write under /etc/facter/facts.d"
#    #defaultto { "/etc/facter/facts.d/#{@resource[:name]}.yaml" }
#    #
#
#    #isnamevar
#
#    defaultto { target = @resource[:name][/.*\/(.*)\.yaml/,1] ? @resource[:name][/.*\/(.*)\.yaml/,1] : @resource[:name] }
#
##    munge do |discard|
##      #return @resource[:name] if discard == @resource[:name]
##      #return @resource[:name][/.*\/(.*)\.yaml/,1]
##      #discard == @resource[:name] ? @resource[:name] : @resource[:name][/.*\/(.*)\.yaml/,1]
##      puts "Target discard: #{discard}"
##      if discard =~ /.*\/(.*)\.yaml/
##        puts "Found #{discard} contains /etc/facter/facts.d, so I'm trimming that"
##        puts "Returning #{discard[/.*\/(.*)\.yaml/,1]}"
##        discard[/.*\/(.*)\.yaml/,1]
##      else
##        puts "Found #{discard} has no path, which is good"
##        discard
##      end
##      #discard =~ /.*\/(.*)\.yaml/ ? @resource[:name] : @resource[:name][/.*\/(.*)\.yaml/,1]
##    end
#  end

  autorequire :file do
#    puts "AUTOREQUIRE /etc/facter/facts.d/#{self[:target]}.yaml"
    "/etc/facter/facts.d/#{self[:name]}.yaml"
  end

end
