describe Travis::Yml::Configs, 'conditionals' do
  let(:repo)    { { slug: 'travis-ci/travis-yml' } }
  let(:configs) { described_class.new(repo, 'master', nil, nil, data, opts).tap(&:load) }
  let(:data)    { { branch: 'master', env: [{ SETTING: 'on' }] } }

  let(:config) { configs.config }
  let(:jobs)   { configs.jobs }
  let(:stages) { configs.stages }
  # let(:msgs)   { subject.msgs.to_a } TODO

  before { stub_repo(repo[:slug], internal: true, body: repo.merge(token: 'token')) }
  before { stub_content(repo[:slug], '.travis.yml', yaml) }

  describe 'jobs' do
    subject { jobs.size }

    describe 'not matching' do
      yaml %(
        jobs:
          include:
          - if: false
      )

      it { should eq 0 }
    end

    describe 'matching branch' do
      yaml %(
        jobs:
          include:
          - if: branch = master
      )

      it { should eq 1 }
    end

    describe 'matching name' do
      yaml %(
        jobs:
          include:
          - name: one
            if: name = one
      )

      xit { should eq 1 }
    end

    describe 'matching env (given as repo setting)' do
      yaml %(
        jobs:
          include:
          - if: env(SETTING) = on
      )

      it { should eq 1 }
    end

    describe 'matching env (given as env.global)' do
      yaml %(
        env:
          global:
            ONE: one
        jobs:
          include:
          - if: env(ONE) = one
      )

      it { should eq 1 }
    end

    describe 'matching env (given as env.jobs, picking the first entry)' do
      yaml %(
        env:
          jobs:
            ONE: one
        jobs:
          include:
          - if: env(ONE) = one
      )

      it { should eq 1 }
    end

    describe 'matching env (given as jobs.include.env)' do
      yaml %(
        jobs:
          include:
          - env: ONE=one
            if: env(ONE) = one
      )

      it { should eq 1 }
    end
  end

  describe 'stages' do
    subject { stages.size }

    describe 'not matching' do
      yaml %(
        stages:
          - name: test
            if: false
        jobs:
          include:
          - name: one
      )

      it { should eq 0 }
    end

    describe 'matching branch' do
      yaml %(
        stages:
          - name: test
            if: branch = master
        jobs:
          include:
          - name: one
      )

      it { should eq 1 }
    end

    describe 'matching env (given as repo setting)' do
      yaml %(
        stages:
          - name: test
            if: env(SETTING) = on
        jobs:
          include:
          - name: one
      )

      it { should eq 1 }
    end

    describe 'matching env (given as env.global)' do
      yaml %(
        env:
          global:
            ONE: one
        stages:
          - name: test
            if: env(ONE) = one
      )

      it { should eq 1 }
    end

    describe 'matching env (given as env.jobs)' do
      yaml %(
        env:
          jobs:
            ONE: one
        stages:
          - name: test
            if: env(ONE) = one
      )

      it { should eq 1 }
    end

    describe 'matching env (given as jobs.include.env)' do
      yaml %(
        stages:
          - name: test
            if: env(ONE) = one
        jobs:
          include:
          - env: ONE=one
      )

      it { should eq 1 }
    end
  end

  describe 'excludes' do
    subject { jobs.size }

    describe 'not matching' do
      yaml %(
        jobs:
          include:
          - name: one
          exclude:
          - if: false
      )

      it { should eq 1 }
    end

    describe 'matching branch' do
      yaml %(
        jobs:
          include:
          - name: one
          exclude:
          - if: branch = master
      )

      it { should eq 0 }
    end

    describe 'matching env (given as repo setting)' do
      yaml %(
        jobs:
          include:
          - name: one
          exclude:
          - if: env(SETTING) = on
      )

      it { should eq 0 }
    end

    describe 'matching env (given as env.global)' do
      yaml %(
        env:
          global:
            ONE: one
        jobs:
          include:
          - name: one
          exclude:
          - if: env(ONE) = one
      )

      it { should eq 0 }
    end

    describe 'matching env (given as env.jobs, picking the first entry)' do
      yaml %(
        env:
          jobs:
            ONE: one
        jobs:
          include:
          - name: one
          exclude:
          - if: env(ONE) = one
      )

      it { should eq 0 }
    end

    describe 'matching env (given as jobs.include.env)' do
      yaml %(
        jobs:
          include:
          - env: ONE=one
          exclude:
            if: env(ONE) = one
      )

      it { should eq 0 }
    end
  end

  describe 'allow_failures' do
    subject { jobs.map { |job| !!job[:allow_failure] } }

    describe 'not matching' do
      yaml %(
        jobs:
          include:
          - name: one
          allow_failures:
          - if: false
      )

      it { expect(subject).to eq [false] }
    end

    describe 'matching branch' do
      yaml %(
        jobs:
          include:
          - name: one
          allow_failures:
          - if: branch = master
      )

      it { expect(subject).to eq [true] }
    end

    describe 'matching env (given as repo setting)' do
      yaml %(
        jobs:
          include:
          - name: one
          allow_failures:
          - if: env(SETTING) = on
      )

      it { expect(subject).to eq [true] }
    end

    describe 'matching env (given as env.global)' do
      yaml %(
        env:
          global:
            ONE: one
        jobs:
          include:
          - name: one
          allow_failures:
          - if: env(ONE) = one
      )

      it { expect(subject).to eq [true] }
    end

    describe 'matching env (given as env.jobs, picking the first entry)' do
      yaml %(
        env:
          jobs:
            ONE: one
        jobs:
          include:
          - name: one
          allow_failures:
          - if: env(ONE) = one
      )

      it { expect(subject).to eq [true] }
    end

    describe 'matching env (given as jobs.include.env)' do
      yaml %(
        jobs:
          include:
          - env: ONE=one
          allow_failures:
            if: env(ONE) = one
      )

      it { expect(jobs.size).to eq 1 }
    end
  end

  describe 'notifications' do
    subject { config[:notifications] }

    describe 'not matching' do
      yaml %(
        notifications:
          email:
          - if: false
      )

      it { expect(subject).to be_nil }
    end

    describe 'matching branch' do
      yaml %(
        notifications:
          email:
          - if: branch = master
      )

      it { expect(subject.size).to eq 1 }
    end

    describe 'matching env (given as repo setting)' do
      yaml %(
        notifications:
          email:
          - if: env(SETTING) = on
      )

      it { expect(subject.size).to eq 1 }
    end

    describe 'matching env (given as env.global)' do
      yaml %(
        env:
          global:
            ONE: one
        notifications:
          email:
          - if: env(ONE) = one
      )

      it { expect(subject.size).to eq 1 }
    end

    describe 'matching env (given as env.notifications, picking the first entry)' do
      yaml %(
        env:
          jobs:
            ONE: one
        notifications:
          email:
          - if: env(ONE) = one
      )

      it { expect(subject).to be_nil } # notifications are not per job
    end

    describe 'matching env (given as notifications.include.env)' do
      yaml %(
        jobs:
          include:
          - env: ONE=one
        notifications:
          email:
          - if: env(ONE) = one
      )

      it { expect(subject).to be_nil } # notifications are not per job
    end
  end
end