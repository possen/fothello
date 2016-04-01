#include <stdio.h>
#include <stdlib.h>
#include <math.h>

char searchDepth;
char originalSearchDepth;
char bruteForceDepth;
char mpcDepth;
bool winLarge;
char randomnessLevel;
bool useAndersson;
bool boardFlipped;
bool showLegalMoves;
// Non essential vars.
bool showDots;
bool showTime;
char selfPlayLimit;
char player1, player2;
#define HUMAN 1
#define COMPUTER 2

#include <fcgi_stdio.h>
#include <stdlib.h>

/* some of the HTTP variables we are interest in */
#define MAX_VARS 30
const char* vars[MAX_VARS] = {
  "DOCUMENT_ROOT",
  "GATEWAY_INTERFACE",
  "HTTP_ACCEPT",
  "HTTP_ACCEPT_ENCODING",
  "HTTP_ACCEPT_LANGUAGE",
  "HTTP_CACHE_CONTROL",
  "HTTP_CONNECTION",
  "HTTP_HOST",
  "HTTP_PRAGMA",
  "HTTP_RANGE",
  "HTTP_REFERER",
  "HTTP_TE",
  "HTTP_USER_AGENT",
  "HTTP_X_FORWARDED_FOR",
  "PATH",
  "QUERY_STRING",
  "REMOTE_ADDR",
  "REMOTE_HOST",
  "REMOTE_PORT",
  "REQUEST_METHOD",
  "REQUEST_URI",
  "SCRIPT_FILENAME",
  "SCRIPT_NAME",
  "SERVER_ADDR",
  "SERVER_ADMIN",
  "SERVER_NAME",
  "SERVER_PORT",
  "SERVER_PROTOCOL",
  "SERVER_SIGNATURE",
    "SERVER_SOFTWARE"
};

int main(void)
{
  int count = 0, i;
  char *v;
  while (FCGI_Accept() >= 0) {
    printf("Content-type: text/plain\r\n\r\n"
	   "Request number %d\n", ++count);
    for (i = 0; i < MAX_VARS; ++i) {
      v = getenv(vars[i]);
      if (v == NULL)
	printf("%s: \n", vars[i]);
      else
	printf("%s: %s\n", vars[i], v);
    }
  }
  return 0;
}

