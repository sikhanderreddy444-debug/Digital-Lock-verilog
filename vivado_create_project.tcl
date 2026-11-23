create_project digital_lock ./digital_lock_vivado -part xc7a100tcsg324-1 -force
add_files digital_lock.v
add_files -fileset sim_1 digital_lock_tb.v
set_property top digital_lock [get_filesets sources_1]
set_property top digital_lock_tb [get_filesets sim_1]
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1
launch_simulation
run all
