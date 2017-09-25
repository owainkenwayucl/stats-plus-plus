all: time-by-cost-by-inst time-by-cost-by-inst-user

time-by-cost-by-inst:
	ln -s shell/r-wrap time-by-cost-by-inst

time-by-cost-by-inst-user:
	ln -s shell/r-wrap time-by-cost-by-inst-user

clean:
	rm time-by-cost-by-inst