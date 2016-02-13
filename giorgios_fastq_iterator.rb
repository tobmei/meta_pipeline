#
# (c) 2013, Giorgio Gonnella, ZBH, Uni Hamburg
#
# %-PURPOSE-%
# Methods to handle FastQ files
# --- BEGIN INCLUDED CODE FROM ./gg_fastx.rb
# --- BEGIN INCLUDED CODE FROM ./gg_seq.rb
# --- BEGIN INCLUDED CODE FROM ./gg_string.rb
class String
  # position of all instances of a substring
  # modified from:
  #   http://stackoverflow.com/questions/3520208/
  #     get-index-of-string-scan-results-in-ruby?lq=1
  def indices(regex)
    arr = []
    scan(regex){arr << $~.offset(0)[0]}
    return arr
  end
  # split string into chunks of given length
  # (the last chunk may be shorter)
  def chunks(length)
    scan(/.{1,#{length}}/)
  end
  # truncate string to given length
  # inspired by:
  #   activesupport/lib/active_support/core_ext/string/filters.rb, line 38
  def truncate(tr_length,opts={})
    return self if length <= tr_length
    omission = opts[:omission] || "..."
    length_with_room_for_omission = tr_length - omission.length
    stop = rindex(" ",length_with_room_for_omission) ||
                      length_with_room_for_omission
    return self[0..stop]+omission
  end
  # show string in lines of width <width>,
  # printing the <pos>-th character with escape code <ecode> (default: red)
  def show_pos(pos, linewidth=50, ecode="0;31;40")
    if pos >= size || pos < -size
      raise "read has only #{size} characters (pos=#{pos})"
    end
    if pos < 0
      pos = size + pos
    end
    remaining=linewidth
    if pos > 0
      chunks=self[0..pos-1].chunks(linewidth)
      remaining-=chunks.last.size
    else
      chunks = [""]
    end
    if remaining == 0
      chunks << ""
      remaining = linewidth
    end
    chunks.last << "\033[#{ecode}m#{self[pos]}\033[0m"
    remaining -= 1
    if remaining > 0
      chunks.last << self[pos+1..pos+remaining]
      remaining = 0
    end
    if pos+remaining < size-1
      chunks << self[pos+remaining+1..size-1].chunks(linewidth)
    end
    puts chunks
  end
  # remove a prefix, and optionally raise an error if prefix not available
  def rm_pfx!(prefix, raise_if_not = true)
    if self[0..prefix.size-1] != prefix
      raise "'#{prefix}' not a prefix of '#{self}'" if raise_if_not
      return self
    end
    replace(slice(prefix.size..-1))
  end
end

# --- END INCLUDED CODE FROM ./gg_string.rb
# --- BEGIN INCLUDED CODE FROM ./gg_gap.rb
class String
  module Gaps
    # array of positions of gap opening
    def gap_openings
      res = indices("-") # do not use lookbehind for 1.8 compatibility
      del = []
      res.each_with_index {|n,i| del << i if res[i-1]==n-1}
      del.each {|i| res[i] = nil}
      res.compact!
      res
    end
    # length of gap opening at position <gap_opening_pos>;
    # if <gap_opening_pos> is not a gap, returns 0
    def gap_length(gap_opening_pos)
      res = self[gap_opening_pos..size-1].index(/[^-]/)
      res.nil? ? size-gap_opening_pos : res
    end
    # remove gaps from sequence
    def ungap
      gsub("-","")
    end
    # length without gaps
    def ungapped_length
      length-scan("-").size
    end
  end
  include Gaps
end

# --- END INCLUDED CODE FROM ./gg_gap.rb
# --- BEGIN INCLUDED CODE FROM ./gg_twobit.rb
class String
  # Functionality related to Two-bit encoding sequence format.
  module Twobit
    TwobitErrMsg1 = "String#twobit: invalid character found"
    # Convert DNA characters into twobit encoding;
    # returns a string with the bits; e.g. "AA" => "0000".
    def twobit
      raise TwobitErrMsg1 if self =~ /[^ACGTU\s]/i
      str = dup
      str.gsub!(/A/i,"00")
      str.gsub!(/C/i,"01")
      str.gsub!(/G/i,"10")
      str.gsub!(/T/i,"11")
      str
    end
  end
  include Twobit
end
class Integer
  # Functionality related to Two-bit encoding sequence format.
  module Twobit
    DecodeTwobitErrMsg1 = "Integer#decode_twobit: value larger than 64-bit"
    DecodeTwobitErrMsg2 = "Integer#decode_twobit: negative value"
    # Decode a 64-bit base-10 integer into a DNA sequence string.
    def decode_twobit
      raise DecodeTwobitErrMsg1 if self > (2 ** 64) - 1
      raise DecodeTwobitErrMsg2 if self < 0
      binary = self.to_i.to_s(4)
      out = ""
      binary.split("").each do |encoded|
        out << "acgt"[encoded.to_i].chr
      end
      prefix = "a" * (32 - out.size)
      prefix+out
    end
  end
  include Twobit
end

# --- END INCLUDED CODE FROM ./gg_twobit.rb
# --- BEGIN INCLUDED CODE FROM ./gg_seqcstats.rb
class String
  # Sequence composition statistics.
  module SeqCStats
    # Character distribution; warning:
    # everything which is not a spacing character or ACTGactg is counted
    # as wildcard without any check.
    def char_distri
      distri = {:A => 0, :C => 0, :G => 0, :T => 0, :wildcards => 0}
      each_char do |c|
        case c
        when "A","a" then distri[:A]+=1
        when "C","c" then distri[:C]+=1
        when "G","g" then distri[:G]+=1
        when "T","t" then distri[:T]+=1
        else
          if c !~ /\s/
            distri[:wildcards]+=1
          end
        end
      end
      distri
    end
    # GC content (only ACTGactg are counted).
    def gc
      cd = char_distri
      cg = cd[:C] + cd[:G]
      total = cg + cd[:A] + cd[:T]
      return cg.to_f/total
    end
    # AT content (only ACTGactg are counted).
    def at
      cd = char_distri
      at = cd[:A] + cd[:T]
      total = at + cd[:C] + cd[:G]
      return at.to_f/total
    end
    # GC skew (only ACTGactg are counted).
    def gc_skew
      cd = char_distri
      cmg = cd[:C] - cd[:G]
      cpg = cd[:C] + cd[:G]
      return cmg.to_f/cpg
    end
    # AT skew (only ACTGactg are counted).
    def at_skew
      cd = char_distri
      amt = cd[:A] - cd[:T]
      apt = cd[:A] + cd[:T]
      return amt.to_f/apt
    end
    # Compute the K-mer spectrum of sequence, for a given k.
    # The string is assume to contain ONLY the sequence, no spacing.
    # Wildcards can be optionally be considered.
    #
    # Options:
    #   skip_wild: skip non atcg, default: false
    #   rel:       relative frequencies, default: absolute counts
    #              (note: wild kmers are not counted)
    #   strand:    strand-specific, default: false
    #              (false means k-mer and its RC are counted together)
    def kmer_spectrum(k, options = {})
      spectrum = {}
      raise "k must be a positive integer" if !k.kind_of?(Integer) or k<=0
      dc=self.downcase
      skip=0
      total=0
      0.upto(length-k) do |startpos|
        if skip > 0
          skip-=1
          next
        end
        endpos = startpos + k - 1
        key = dc[startpos..endpos]
        if options[:skip_wild] and key.index(/[^acgt]/)
          # one can skip this and the next k-1 positions
          skip = k-1
          next
        end
        if !options[:strand]
          keyrc = key.revcompl
          if key > keyrc
            key = keyrc
          end
        end
        key = key.to_sym
        spectrum[key]||=0
        spectrum[key]+=1
        total+=1
      end
      if (options[:rel])
        spectrum.keys.each do |key|
          spectrum[key] = spectrum[key].to_f / total
        end
      end
      spectrum
    end
  end
  include SeqCStats
end

# --- END INCLUDED CODE FROM ./gg_seqcstats.rb
# --- BEGIN INCLUDED CODE FROM ./gg_wildcards.rb
class String
  Wildcards = {"N" => ["A","C","G","T"],
               "B" => ["C","G","T"],
               "H" => ["A","C","T"],
               "D" => ["A","G","T"],
               "V" => ["A","C","G"],
               "R" => ["A","G"],
               "Y" => ["C","T"],
               "S" => ["C","G"],
               "W" => ["A","T"],
               "K" => ["G","T"],
               "M" => ["A","C"]}
  # does the sequence contain anything except ACTG?
  def wild?
    self =~ /[^ACGTacgt\s]/
  end
  def expand_wildcards
    oseqs=[""]
    each_char do |char|
      char.upcase!
      if %w{A C G T}.include?(char)
        oseqs.map!{|oseq| oseq+char}
      elsif Wildcards.keys.include?(char)
        oseqs_expanded = []
        oseqs.each do |oseq|
          expansion[char].each do |echar|
            oseqs_expanded << "#{oseq}#{echar}"
          end
        end
        oseqs = oseqs_expanded
      elsif char !~ /\s/
        raise "Unknown char in sequence: '#{char}'"
      end
    end
    return oseqs
  end
end

# --- END INCLUDED CODE FROM ./gg_wildcards.rb
class String
  module DoubleStrand
    # reverse complement sequence
    def revcompl
      each_char.map{|c|c.wcc}.reverse.join
    end
    WCC = {"a"=>"t","c"=>"g","g"=>"c","t"=>"a","-"=>"-",
           "A"=>"T","C"=>"G","G"=>"C","T"=>"A","n"=>"n",
           "N"=>"N"}
    # Watson-Crick complement of base (single-character string)
    def wcc
      raise "String#wcc: string must be a single character (#{self})" if size != 1
      res = WCC[self]
      raise "#{self}: no Watson-Crick complement defined" if res.nil?
      res
    end
  end
  include DoubleStrand
  include SeqCStats
end

# --- END INCLUDED CODE FROM ./gg_seq.rb
class String
  # extract FastaID from description line
  def fastaid
    self[1..-1].split[0]
  end
end
class FastxUnit
  attr_accessor :seq,:desc,:seqnum
  def fastaid; desc.fastaid; end
  def wild?; seq.wild?; end
  def twobit; seq.twobit; end
end
class FastxFile < File
  attr_reader :seqnum
  def skipwild
    @skipwild = true
  end
  def initialize(fname)
    @seqnum = -1
    super(fname,"r")
  end
  def each
    while unit = get
      yield unit
    end
  end
  def to_hash
    hsh=Hash.new
    each{|u|hsh[u.fastaid.to_sym]=u.seq}
    return hsh
  end
  def search(fastaid)
    while unit = get
      return unit if unit.fastaid == fastaid
    end
    return nil
  end
  def self.search(fastaid,fname)
    u=nil
    open(fname){|f| u = f.search(fastaid)}
    raise "Read #{fastaid} not found in #{fname}" if u.nil?
    return u
  end
  def rewind
    @seqnum = -1
    super
  end
  def get_by_seqnum(seqnum)
    rewind if @seqnum > seqnum
    while @seqnum < seqnum
      get
      return nil if @unit.nil?
    end
    return @unit
  end
end

# --- END INCLUDED CODE FROM ./gg_fastx.rb

class FastqUnit < FastxUnit
  attr_accessor :qdesc,:qual
  def initialize(desc,seq,qdesc,qual,seqnum)
    @desc,@seq,@qdesc,@qual,@seqnum=desc,seq,qdesc,qual,seqnum
    validate!
    self
  end
  def validate!
    raise "Malformed FastQ unit:#{self.inspect}" \
      unless desc[0..0]=="@" and
             qdesc[0..0]=="+" and
             seq.size==qual.size
  end
end

class FastqFile < FastxFile
  def get
    (sd=gets or return @unit=nil) and sd.chomp!
    (s=gets or return @unit=nil) and s.chomp!
    (qd=gets or return @unit=nil) and qd.chomp!
    (q=gets or return @unit=nil) and q.chomp!
    return get if s.wild? and @skipwild
    @seqnum += 1
    @unit=FastqUnit.new(sd,s,qd,q,@seqnum)
  end
  # faster than self.search, does not compute the seqnum
  # will fail if fastaIDs are not unique
  def self.grep_search(fastaid,fname)
    text=`grep -P -A3 '^@#{fastaid}$|^@#{fastaid}\s' #{fname}`
    raise "Read #{fastaid} not found in #{fname}" if text.empty?
    sd,s,qs,q=text.split("\n").map{|l|l.chomp}
    u=FastqUnit.new(sd,s,qs,q,nil)
    return u
  end
end

class FastqFileArray
  def initialize(*filenames)
    @files = filenames.map {|fname| FastqFile.new(fname)}
    self
  end
  def skipwild
    @skipwild=true
  end
  def get
    retvals = @files.map {|f|f.get}
    return nil if retvals.any?{|u|u.nil?}
    return get if retvals.any?{|u|u.wild?} and @skipwild
    retvals
  end
  def each
    while units = get
      yield(units)
    end
  end
end
