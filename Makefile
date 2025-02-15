.PHONY := backup clear kill restore

SRC_DIR=SOURCE
BCK_DIR=BACKUP
INT_SEC=5
MAX_BCK=3

backup: kill
	@if [ ! -d $(BCK_DIR) ]; then \
		mkdir $(BCK_DIR); \
	fi;
	@./backupd.sh $(SRC_DIR) $(BCK_DIR) $(INT_SEC) $(MAX_BCK) &

clear: kill
	@rm -f directory-info.*
	@rm -rf $(BCK_DIR)/*
	@for file in $(SRC_DIR)/*; do \
        if [ -f "$$file" ]; then \
            > "$$file"; \
        fi; \
    done

restore: kill
	@./restore.sh $(SRC_DIR) $(BCK_DIR)

kill:
	@if pgrep -x 'backupd.sh' > /dev/null; then \
		pkill 'backupd.sh'; \
	fi; 
	@if pgrep -x 'restore.sh' > /dev/null; then \
		pkill 'backupd.sh'; \
	fi; 