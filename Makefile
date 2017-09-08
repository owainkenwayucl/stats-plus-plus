all: time-by-cost-by-inst

time-by-cost-by-inst:
	ln -s shell/r-wrap time-by-cost-by-inst

clean:
	rm time-by-cost-by-inst