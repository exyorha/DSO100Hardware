make_wrapper -top -files [get_files dso100.bd]
set root [get_property DIRECTORY [current_project]]
add_files -norecurse $root/DSO100Hardware.srcs/sources_1/bd/dso100/hdl/dso100_wrapper.v
set_property top dso100_wrapper [get_filesets sources_1]
update_compile_order -fileset sources_1
update_compile_order -fileset sim_1
