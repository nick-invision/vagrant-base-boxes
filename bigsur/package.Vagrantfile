ENV["VAGRANT_EXPERIMENTAL"] = "typed_triggers"

Vagrant.configure("2") do |config|
    config.vm.synced_folder ".", "/vagrant", disabled: true
    config.vm.provider "virtualbox" do |v|
        v.check_guest_additions = false
    end
    config.trigger.after :"VagrantPlugins::ProviderVirtualBox::Action::Import", type: :action do |t|
        t.ruby do |env, machine|
            FileUtils.cp(
                machine.box.directory.join("include").join("macOS.nvram").to_s,
                machine.provider.driver.execute_command(["showvminfo", machine.id, "--machinereadable"]).
                    split(/\n/).
                    map {|line| line.partition(/=/)}.
                    select {|partition| partition.first == "BIOS NVRAM File"}.
                    last.
                    last[1..-2]
            )
        end
    end
end