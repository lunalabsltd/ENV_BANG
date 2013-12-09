require_relative 'test_helper'

describe ENV_BANG do
  it "Raises exception if unconfigured ENV var requested" do
    ENV['UNCONFIGURED'] = 'unconfigured'
    proc { ENV!['UNCONFIGURED'] }.must_raise KeyError
  end

  it "Raises exception if configured ENV var is not present" do
    ENV.delete('NOT_PRESENT')

    proc {
      ENV!.config do
        use 'NOT_PRESENT'
      end
    }.must_raise KeyError
  end

  it "Includes provided description in error message" do
    ENV.delete('NOT_PRESENT')

    e = proc {
      ENV!.config do
        use 'NOT_PRESENT', 'You need a NOT_PRESENT var in your ENV'
      end
    }.must_raise(KeyError)
    e.message.must_include 'You need a NOT_PRESENT var in your ENV'
  end

  it "Uses provided default value if ENV var not already present" do
    ENV.delete('WASNT_PRESENT')

    ENV!.config do
      use 'WASNT_PRESENT', default: 'a default value'
    end
    ENV!['WASNT_PRESENT'].must_equal 'a default value'
  end

  it "Returns actual value from ENV if present" do
    ENV['PRESENT'] = 'present in environment'

    ENV!.config do
      use 'PRESENT', default: "You won't need this."
    end
    ENV!['PRESENT'].must_equal 'present in environment'
  end

  describe "Type casting" do
    let(:truthy_values) { %w[true on yes yo yup anything] }
    let(:falsey_values) { %w[false no off disable disabled 0] << '' }
    let(:integers) { %w[0 1 10 -42 -55] }
    let(:floats) { %w[0.1 1.3 10 -42.3 -55] }

    it "Casts Integers" do
      integer = integers.sample
      ENV['INTEGER'] = integer
      ENV!.use 'INTEGER', class: Integer

      ENV!['INTEGER'].must_equal integer.to_i
    end

    it "Casts Floats" do
      float = floats.sample
      ENV['FLOAT'] = float
      ENV!.use 'FLOAT', class: Float

      ENV!['FLOAT'].must_equal float.to_f
      ENV!['FLOAT'].class.must_equal Float
    end

    it "Casts Arrays" do
      ENV['ARRAY'] = 'one,two , three, four'
      ENV!.use 'ARRAY', class: Array

      ENV!['ARRAY'].must_equal %w[one two three four]
    end

    it "Casts Arrays of Integers" do
      ENV['INTEGERS'] = integers.join(',')
      ENV!.use 'INTEGERS', class: Array, of: Integer

      ENV!['INTEGERS'].must_equal integers.map(&:to_i)
    end

    it "Casts Arrays of Floats" do
      ENV['FLOATS'] = floats.join(',')
      ENV!.use 'FLOATS', class: Array, of: Float

      ENV!['FLOATS'].must_equal floats.map(&:to_f)
    end

    it "Casts false" do
      ENV['TRUE'] = truthy_values.sample
      ENV!.use 'TRUE', class: :boolean

      ENV!['TRUE'].must_equal true
    end

    it "Casts false" do
      ENV['FALSE'] = falsey_values.sample
      ENV!.use 'FALSE', class: :boolean

      ENV!['FALSE'].must_equal false
    end
  end
end
