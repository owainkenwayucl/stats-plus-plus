all: time-by-cost-by-inst time-by-cost-by-inst-user unique-users-over-all-time usage-by-faculty usage-by-department

time-by-cost-by-inst:
	ln -s shell/r-wrap time-by-cost-by-inst

time-by-cost-by-inst-user:
	ln -s shell/r-wrap time-by-cost-by-inst-user

unique-users-over-all-time:
	ln -s shell/python-wrap unique-users-over-all-time

usage-by-faculty:
	ln -s shell/python-wrap usage-by-faculty

usage-by-department:
	ln -s shell/python-wrap usage-by-department

clean:
	rm time-by-cost-by-inst time-by-cost-by-inst-user unique-users-over-all-time usage-by-faculty usage-by-department