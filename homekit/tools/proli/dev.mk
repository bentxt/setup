all:
	@#blog test
	@#sh ./proliblog.sh -w -a ../archive/2024 readme.md
	sh ./proliblog.sh -w --suffix ../archive/2024 readme.md

clean:
	rm -rf 20*
