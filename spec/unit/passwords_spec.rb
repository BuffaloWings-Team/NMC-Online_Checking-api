# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Password Digestion' do
  it 'SECURITY: create password digests safely, hiding raw password' do
    password = 'secret password of 西蒙 stored in db'
    digest = OnlineCheckIn::Password.digest(password)

    _(digest.to_s.match?(password)).must_equal false
  end

  it 'SECURITY: successfully checks correct password from stored digest' do
    password = 'secret password of 西蒙 stored in db'
    digest_s = OnlineCheckIn::Password.digest(password).to_s

    digest = OnlineCheckIn::Password.from_digest(digest_s)
    _(digest.correct?(password)).must_equal true
  end

  it 'SECURITY: successfully detects incorrect password from stored digest' do
    password1 = 'secret password of 西蒙 stored in db'
    password2 = 'IFyouwishtomakeblackberrypieyoumustfirstinventablackhole'
    digest_s1 = OnlineCheckIn::Password.digest(password1).to_s

    digest1 = OnlineCheckIn::Password.from_digest(digest_s1)
    _(digest1.correct?(password2)).must_equal false
  end
end
