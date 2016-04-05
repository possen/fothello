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

#include <fcgio.h>
#include <stdlib.h>
#include <string>
#include <iostream>
#include "board.hpp"

using namespace std;

// Maximum bytes
const unsigned long STDIN_MAX = 1000000;

/**
 * Note this is not thread safe due to the static allocation of the
 * content_buffer.
 */
string get_request_content(const FCGX_Request & request) {
  char * content_length_str = FCGX_GetParam("CONTENT_LENGTH", request.envp);
  unsigned long content_length = STDIN_MAX;

  if (content_length_str) {
    content_length = strtol(content_length_str, &content_length_str, 10);
    if (*content_length_str) {
      cerr << "Can't Parse 'CONTENT_LENGTH='"
	   << FCGX_GetParam("CONTENT_LENGTH", request.envp)
	   << "'. Consuming stdin up to " << STDIN_MAX << endl;
    }

    if (content_length > STDIN_MAX) {
      content_length = STDIN_MAX;
    }
  } else {
    // Do not read from stdin if CONTENT_LENGTH is missing
    content_length = 0;
  }

  char * content_buffer = new char[content_length];
  cin.read(content_buffer, content_length);
  content_length = cin.gcount();

  // Chew up any remaining stdin - this shouldn't be necessary
  // but is because mod_fastcgi doesn't handle it correctly.

  // ignore() doesn't set the eof bit in some versions of glibc++
  // so use gcount() instead of eof()...
  do cin.ignore(1024); while (cin.gcount() == 1024);

  string content(content_buffer, content_length);
  delete [] content_buffer;
  return content;
}

int main(void)
{
  // Backup the stdio streambufs
  streambuf * cin_streambuf  = cin.rdbuf();
  streambuf * cout_streambuf = cout.rdbuf();
  streambuf * cerr_streambuf = cerr.rdbuf();

  FCGX_Request request;

  FCGX_Init();
  FCGX_InitRequest(&request, 0, 0);

  while (FCGX_Accept_r(&request) == 0) {
    fcgi_streambuf cin_fcgi_streambuf(request.in);
    fcgi_streambuf cout_fcgi_streambuf(request.out);
    fcgi_streambuf cerr_fcgi_streambuf(request.err);

    cin.rdbuf(&cin_fcgi_streambuf);
    cout.rdbuf(&cout_fcgi_streambuf);
    cerr.rdbuf(&cerr_fcgi_streambuf);

    const char * uri = FCGX_GetParam("REQUEST_URI", request.envp);

    string content = get_request_content(request);
    string jsonResp = getMoveFromJSON(content);

    cout << "Content-type: application/json\r\n" 
         << "\r\n"
	 << jsonResp << "\r\n";

    // Note: the fcgi_streambuf destructor will auto flush
  }

  // restore stdio streambufs
  cin.rdbuf(cin_streambuf);
  cout.rdbuf(cout_streambuf);
  cerr.rdbuf(cerr_streambuf);

  return 0;
}

