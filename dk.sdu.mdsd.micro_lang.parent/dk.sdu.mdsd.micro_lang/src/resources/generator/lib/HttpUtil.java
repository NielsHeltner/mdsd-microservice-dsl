package lib;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.OutputStream;
import java.util.Arrays;
import java.util.Map;
import java.util.stream.Collectors;

import com.sun.net.httpserver.HttpExchange;

public class HttpUtil {
	
	private final String keyValueSeparator = "=";
    private final String parameterSeparator = "&";
	
	/**
     * Converts a String of parameters of the format
     * 'parameterName=parameterValue', where each pair is separated with an '&',
     * to a map where the key is parameter name and the value is the parameter
     * value.
     *
     * @param parameters
     * @return
     */
    public Map<String, Object> toMap(String parameters) {
        return Arrays.stream(parameters.split(parameterSeparator))
        	.map(parameter -> parameter.split(keyValueSeparator))
        	.collect(Collectors
			.toMap(param -> param[0], param -> param[1]));
    }
	
	public String getBody(InputStream bodyStream) {
		StringBuilder result = new StringBuilder();
		try {
			BufferedReader reader = new BufferedReader(new InputStreamReader(bodyStream));
			while (reader.ready()) {
				result.append(reader.readLine());
			}
		}
		catch (IOException e) {
			e.printStackTrace();
		}
		return result.toString();
	}
	
	public void sendResponse(HttpExchange exchange, int code, String response) {
		try {
			System.out.println(response);
			exchange.sendResponseHeaders(code, response.length());
			OutputStream os = exchange.getResponseBody();
			os.write(response.getBytes());
			os.close();
		}
		catch (IOException e) {
			e.printStackTrace();
		}
	}
	
	public void sendResponse(HttpExchange exchange, int code) {
		sendResponse(exchange, code, "");
	}
	

}
