ngx_int_t ngx_http_complex_value_noalloc(ngx_http_request_t *r, ngx_http_complex_value_t *val, ngx_str_t *value, size_t maxlen);
u_char *nchan_strsplit(u_char **s1, ngx_str_t *sub, u_char *last_char);
ngx_str_t *nchan_get_header_value(ngx_http_request_t * r, ngx_str_t header_name);
ngx_str_t *nchan_get_header_value_origin(ngx_http_request_t *r, nchan_request_ctx_t *ctx);

int nchan_match_origin_header(ngx_http_request_t *r, nchan_loc_conf_t *cf, nchan_request_ctx_t *ctx);
ngx_str_t *nchan_get_allow_origin_value(ngx_http_request_t *r, nchan_loc_conf_t *cf, nchan_request_ctx_t *ctx);

ngx_str_t *nchan_get_accept_header_value(ngx_http_request_t *r);
ngx_buf_t *nchan_chain_to_single_buffer(ngx_pool_t *pool, ngx_chain_t *chain, size_t content_length);
ngx_str_t *ngx_http_debug_pool_str(ngx_pool_t *pool);
int nchan_strmatch(ngx_str_t *val, ngx_int_t n, ...);
int nchan_cstrmatch(char *cstr, ngx_int_t n, ...);
int nchan_cstr_startswith(char *cstr, char *match);

void nchan_scan_split_by_chr(u_char **cur, size_t max_len, ngx_str_t *str, u_char chr);
void nchan_scan_until_chr_on_line(ngx_str_t *line, ngx_str_t *str, u_char chr);

int nchan_ngx_str_match(ngx_str_t *str1, ngx_str_t *str2);

void nchan_strcpy(ngx_str_t *dst, ngx_str_t *src, size_t maxlen);
ngx_int_t nchan_init_timer(ngx_event_t *ev, void (*cb)(ngx_event_t *), void *pd);
ngx_int_t nchan_add_oneshot_timer(void (*cb)(void *), void *pd, ngx_msec_t delay);
ngx_int_t nchan_add_interval_timer(int (*cb)(void *), void *pd, ngx_msec_t interval);
char *nchan_msgstatus_to_str(nchan_msg_status_t status);
ngx_int_t nchan_strscanstr(u_char **cur, ngx_str_t *find, u_char *last);

char *nchan_conf_set_size_slot(ngx_conf_t *cf, ngx_command_t *cmd, void *conf);
ssize_t nchan_parse_size(ngx_str_t *line);

int nchan_ngx_str_char_substr(ngx_str_t *str, char *substr, size_t sz);
#define nchan_ngx_str_substr(str, substr) \
  nchan_ngx_str_char_substr(str, substr, sizeof(substr)-1)
  
#define nchan_strstrn(haystack, needle) ngx_strstrn((u_char *)(haystack), (needle), sizeof(needle) - 2)

#ifndef container_of

#define container_of(ptr, type, member) ({                      \
        const typeof( ((type *)0)->member ) *__mptr = (ptr);    \
        (type *)( (char *)__mptr - offsetof(type,member) );})
#endif
