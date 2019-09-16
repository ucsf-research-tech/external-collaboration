package org.projectredcap.main;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.List;

import org.apache.http.HttpResponse;
import org.apache.http.NameValuePair;
import org.apache.http.client.HttpClient;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.impl.client.HttpClientBuilder;
import org.apache.http.message.BasicNameValuePair;
import org.json.simple.JSONArray;
import org.json.simple.JSONObject;

public class ImportUserRights
{
	private final List<NameValuePair> params;
	private final HttpPost post;
	private HttpResponse resp;
	private final HttpClient client;
	private int respCode;
	private BufferedReader reader;
	private final StringBuffer result;
	private String line;
	private final JSONObject record;
	private final JSONArray data;

	@SuppressWarnings("unchecked")
	public ImportUserRights(final Config c)
	{
		record = new JSONObject();
		record.put("username", "test_user_47");
		record.put("expiration", "2016-01-01");
		record.put("data_access_group", "1");
		record.put("data_export", "1");
		record.put("mobile_app", "1");
		record.put("mobile_app_download_data", "1");
		record.put("lock_record_multiform", "1");
		record.put("lock_record", "1");
		record.put("lock_record_customize", "1");
		record.put("record_delete", "1");
		record.put("record_rename", "1");
		record.put("record_create", "1");
		record.put("api_import", "1");
		record.put("api_export", "1");
		record.put("data_quality_execute", "1");
		record.put("data_quality_design", "1");
		record.put("file_repository", "1");
		record.put("data_logging", "1");
		record.put("data_comparison_tool", "1");
		record.put("data_import_tool", "1");
		record.put("calendar", "1");
		record.put("graphical", "1");
		record.put("reports", "1");
		record.put("user_rights", "1");
		record.put("design", "1");

		data = new JSONArray();
		data.add(record);

		params = new ArrayList<NameValuePair>();
		params.add(new BasicNameValuePair("token", c.API_TOKEN));
		params.add(new BasicNameValuePair("content", "user"));
		params.add(new BasicNameValuePair("format", "json"));
		params.add(new BasicNameValuePair("data", data.toJSONString()));

		post = new HttpPost(c.API_URL);
		post.setHeader("Content-Type", "application/x-www-form-urlencoded");

		try
		{
			post.setEntity(new UrlEncodedFormEntity(params));
		}
		catch (final Exception e)
		{
			e.printStackTrace();
		}

		result = new StringBuffer();
		client = HttpClientBuilder.create().build();
		respCode = -1;
		reader = null;
		line = null;
	}

	public void doPost()
	{
		resp = null;

		try
		{
			resp = client.execute(post);
		}
		catch (final Exception e)
		{
			e.printStackTrace();
		}

		if(resp != null)
		{
			respCode = resp.getStatusLine().getStatusCode();

			try
			{
				reader = new BufferedReader(new InputStreamReader(resp.getEntity().getContent()));
			}
			catch (final Exception e)
			{
				e.printStackTrace();
			}
		}

		if(reader != null)
		{
			try
			{
				while((line = reader.readLine()) != null)
				{
					result.append(line);
				}
			}
			catch (final Exception e)
			{
				e.printStackTrace();
			}
		}

		System.out.println("respCode: " + respCode);
		System.out.println("result: " + result.toString());
	}
}
