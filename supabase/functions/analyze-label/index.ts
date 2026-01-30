import { serve } from "https://deno.land/std@0.168.0/http/server.ts";

const GEMINI_API_KEY = Deno.env.get("GEMINI_API_KEY");
const GEMINI_API_URL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

interface AnalyzeRequest {
  image: string; // base64 encoded image
}

interface AnalyzeResponse {
  name: string | null;
  brewery: string | null;
  debug?: {
    rawResponse: string;
    parsedJson: string;
  };
}

serve(async (req) => {
  // CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    if (!GEMINI_API_KEY) {
      throw new Error("GEMINI_API_KEY is not set");
    }

    const { image }: AnalyzeRequest = await req.json();

    if (!image) {
      throw new Error("image is required");
    }

    // base64 데이터에서 prefix 제거 (있다면)
    const base64Data = image.replace(/^data:image\/\w+;base64,/, "");

    const prompt = `이 막걸리 라벨 이미지에서 제품 정보를 추출해주세요.

응답 형식 (JSON만 반환, 다른 텍스트 없이):
{
  "name": "막걸리 제품명",
  "brewery": "양조장명 또는 null"
}

규칙:
- name은 라벨에서 가장 크게 표시된 브랜드/제품명입니다
- brewery는 제조사/양조장명입니다 (없으면 null)
- 막걸리가 아니거나 텍스트를 읽을 수 없으면 {"name": null, "brewery": null} 반환
- JSON만 반환하고 다른 설명은 하지 마세요`;

    const response = await fetch(`${GEMINI_API_URL}?key=${GEMINI_API_KEY}`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        contents: [
          {
            parts: [
              { text: prompt },
              {
                inline_data: {
                  mime_type: "image/jpeg",
                  data: base64Data,
                },
              },
            ],
          },
        ],
        generationConfig: {
          temperature: 0.1,
          maxOutputTokens: 1024,
        },
      }),
    });

    if (!response.ok) {
      const errorText = await response.text();
      console.error("Gemini API error:", errorText);
      throw new Error(`Gemini API error: ${response.status}`);
    }

    const data = await response.json();

    console.log("=== Full Gemini API Response ===");
    console.log(JSON.stringify(data, null, 2));
    console.log("=== End Full Response ===");

    // Gemini 응답에서 텍스트 추출 (여러 parts가 있을 수 있음)
    const parts = data.candidates?.[0]?.content?.parts || [];
    let generatedText = "";
    for (const part of parts) {
      if (part.text) {
        generatedText += part.text;
      }
    }

    console.log("=== Combined Text ===");
    console.log(generatedText);
    console.log("=== End Combined Text ===");

    console.log("=== Gemini Raw Response ===");
    console.log(generatedText);
    console.log("=== End Raw Response ===");

    // JSON 파싱 (코드 블록 제거)
    let jsonText = generatedText.trim();
    if (jsonText.startsWith("```json")) {
      jsonText = jsonText.slice(7);
    }
    if (jsonText.startsWith("```")) {
      jsonText = jsonText.slice(3);
    }
    if (jsonText.endsWith("```")) {
      jsonText = jsonText.slice(0, -3);
    }
    jsonText = jsonText.trim();

    console.log("=== Cleaned JSON Text ===");
    console.log(jsonText);
    console.log("=== End Cleaned JSON ===");

    let result: AnalyzeResponse;
    try {
      const parsed = JSON.parse(jsonText);
      result = {
        name: parsed.name,
        brewery: parsed.brewery,
        debug: {
          rawResponse: generatedText,
          parsedJson: jsonText
        }
      };
      console.log("Parsed successfully:", result);
    } catch (parseError) {
      console.error("Failed to parse JSON:", jsonText);
      console.error("Parse error:", parseError);
      result = {
        name: null,
        brewery: null,
        debug: {
          rawResponse: generatedText,
          parsedJson: jsonText
        }
      };
    }

    return new Response(JSON.stringify(result), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (error) {
    console.error("Error:", error);
    return new Response(
      JSON.stringify({ error: error.message }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      }
    );
  }
});
