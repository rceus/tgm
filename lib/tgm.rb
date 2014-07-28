require "tgm/version"
require "gmail"
require "thor"
require "shellwords"

module Tgm
  # Your code goes here...
  class CLI < Thor 
    desc 'login', 'Log into your gmail account.'
    def login
      $username = ask 'Enter your username:'
      $password = ask 'Enter your password:'
      gmail = Gmail.connect!($username, $password)
      say 'User Authorized!'
    end
    desc 'mail', 'Send an email.'
    def mail
      $username = ask 'Enter your username:'
      $password = ask 'Enter your password:'
      gmail = Gmail.connect!($username, $password)
      to_mail = ask 'Enter email-id:'
      subject_mail = ask 'Enter subject:'
      body_mail = ask 'Enter body:'
      email=gmail.compose do
        to to_mail
        subject subject_mail
        body body_mail
      end
      gmail.deliver(email)
      gmail.logout
    end
    desc 'inbox', 'Get your inbox statistics'
    def inbox
      $username = ask 'Enter your username:'
      $password = ask 'Enter your password:'
      gmail = Gmail.connect!($username, $password)
      noInbox=gmail.inbox.count
      noUnread=gmail.inbox.count(:unread)
      noRead=gmail.inbox.count(:read)
      say 'Number of Mails: '+noInbox.to_s
      say 'Number of Unread Mails: '+noUnread.to_s
      say 'Number of Read Mails: '+noRead.to_s
      gmail.logout
    end
    desc 'labels', 'Manage your labels'
    method_option :all, :type => :boolean
    method_option :name #:aliases => '-n'
    method_option :create #:aliases => '-c'
    def labels
      $username = ask 'Enter your username:'
      $password = ask 'Enter your password:'
      gmail = Gmail.connect!($username, $password)
      if options[:all]==true
        @labels=gmail.labels.all
        say 'All Labels:'
        @labels.each do |name|
          say name
        end
      end
      if options[:name]
        noEmailsInLabel=gmail.mailbox(options[:name]).count
        say 'Number of mails in '+(options[:name]).to_s+': '+noEmailsInLabel.to_s
      end
      if options[:create]
        gmail.labels.add(options[:create])
        say 'Label '+options[:create].to_s+' created'
      end
      gmail.logout
    end
    desc 'from', 'Get mails from a specific address'
    method_option :user, :required => true
    def from
      $username = ask 'Enter your username:'
      $password = ask 'Enter your password:'
      gmail = Gmail.connect!($username, $password)
      say 'Emails from: '+options[:user].to_s
      say 'Count: '+gmail.mailbox('[Gmail]/All Mail').count(:from => options[:user]).to_s
      @messages=gmail.mailbox('[Gmail]/All Mail').search(:from => options[:user])
      @messages.each do |email|
        say email.raw_message
      end
      gmail.logout
    end
  end
end

