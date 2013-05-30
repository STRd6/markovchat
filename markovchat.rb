require 'pp'

class MarkovChat
  def initialize(data=nil)
    @nextwords = data || Hash.new
    @nextwords_total = {}
  end

  def database
    @nextwords
  end

  def nw
    @nextwords
  end

  def random_pair
    @nextwords.keys.sample
  end

  def pair_starting_with(word)
    word = word.to_sym
    @nextwords.keys.select {|k| k.first == word}.sample
  end

  def random_start
    until (ks = random_pair).first.nil?; end
    #ks = @nextwords.keys.select{|ws| ws[0] == nil }
    #w0, w1 = ks[ rand(ks.size) ]
    w0, w1 = ks
    [w1, nextword(w0,w1)]
  end

  def chat(*args)
    args = pair_starting_with(args.first) if args.size == 1

    while args.size != 2 or args.any?{|arg| arg.nil?}
      args = random_start
    end

    w1, w2    = args.map{|w| w.to_sym}
    sentence  = [w1, w2]

    while nw = nextword(w1, w2)
      sentence << nw
      w1,w2 = w2,nw
    end

    sentence.join(" ")
  end

  def total(key)
    @nextwords_total[key] ||= 0
  end

  def inc_total(key)
    @nextwords_total[key] ||= 0
    @nextwords_total[key] += 1
  end

  def nextwords(key)
    @nextwords[key] ||= {}
  end

  def nextword(w1, w2)
    #p [:nextword, w1, w2]
    key     = [w1,w2]
    nexts   = nextwords(key)
    thresh  = rand(total(key))
    total   = 0
    nw      = nil

    for word, num in nexts
      total += num
      if total > thresh
        nw = word
        break
      end
    end

    nw
  end

  def add_sentence(sentence)
    ws = [nil] + sentence.split.map{|w| w.to_sym} + [nil]
    for i in (0...ws.size-2)
      add_triple( *ws[i..i+2] )
    end
  end

  def add_triple(w1, w2, w3)
    key = [w1,w2]
    nexts = nextwords(key)
    nexts[w3] ||= 0
    nexts[w3] += 1
    inc_total(key)
  end

  def dump
    puts "-"*50
    puts "Contents of markov database:"
    puts "="*50
    pp [:nextwords, @nextwords]
    puts
  end
end



if $0 == __FILE__

  m = MarkovChat.new

  m.add_sentence("hi there how are you")
  m.add_sentence("how is trix doing")
  m.add_sentence("hey dude what's up")
  m.add_sentence("totally man")
  m.add_sentence("hi there you are groovy")
  m.add_sentence("hi there you are amazing")
  m.add_sentence("hi there you are a manly man")
  m.add_sentence("you are totally loco")
  m.add_sentence("you are stinky")
  m.add_sentence("you are badical")

  p [:pair_starting_with, m.pair_starting_with("hi")]
  p [:pair_starting_with, m.pair_starting_with("hi")]

  p m.chat("hi", "there")

  5.times do
    p m.chat
  end

end
