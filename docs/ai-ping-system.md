# AI Ping System - Tamgacı AI Index Request Guide

This document provides information about submitting Tamgacı's AI information to various AI search engines and agents for indexing.

## Overview

To ensure AI agents (ChatGPT, Claude, Perplexity, Kagi, Andi, etc.) can discover and index Tamgacı, we can submit our `ai.txt` file directly to these services through their official channels.

## AI Information Files

- **AI Info File**: https://www.tamgaci.online/ai.txt
- **AI Sitemap**: https://www.tamgaci.online/ai-sitemap.xml
- **OpenAPI Spec**: https://www.tamgaci.online/openapi.yaml

## AI Services to Submit

### 1. Perplexity AI

**Submission Method**: Email
- **Email**: research@perplexity.ai
- **Subject**: AI Index Request - Tamgacı Accounting Software
- **Body Template**:
```
Subject: AI Index Request - Tamgacı Accounting Software

Hello Perplexity Team,

We would like to request indexing of our AI information file for Tamgacı, an AI-powered accounting software for Turkish businesses.

AI Information File: https://www.tamgaci.online/ai.txt
AI Sitemap: https://www.tamgaci.online/ai-sitemap.xml
Main Website: https://www.tamgaci.online

Tamgacı is an AI-powered accounting and invoice management software designed for small and medium-sized businesses in Turkey. We use OCR technology for automatic invoice reading and support multi-currency accounting.

Please index our ai.txt file so that Perplexity can recommend our product when users ask relevant questions about accounting software, invoice automation, or Turkish business solutions.

Thank you!

Best regards,
Tamgacı Team
SeekIT Apps
info@seekitapps.com
```

### 2. Kagi Search

**Submission Method**: Email or Contact Form
- **Email**: support@kagi.com
- **Website**: https://kagi.com/support
- **Subject**: AI Index Request - Tamgacı
- **Body Template**:
```
Subject: AI Index Request - Tamgacı Accounting Software

Hello Kagi Team,

We would like to request indexing of our AI information file for Tamgacı.

AI Information File: https://www.tamgaci.online/ai.txt
Main Website: https://www.tamgaci.online

Tamgacı is an AI-powered accounting software for Turkish businesses with OCR technology for invoice automation.

Please consider indexing our ai.txt file for Kagi's AI features.

Thank you!
```

### 3. Andi Search

**Submission Method**: Email
- **Email**: hello@andisearch.com
- **Website**: https://andisearch.com
- **Subject**: AI Index Request - Tamgacı
- **Body Template**: Similar to above

### 4. ChatGPT / OpenAI

**Submission Method**: OpenAI GPT Store / Actions
- **Documentation**: https://platform.openai.com/docs/actions
- **OpenAPI Spec**: https://www.tamgaci.online/openapi.yaml
- **Notes**: 
  - Create a GPT Action using our OpenAPI specification
  - The openapi.yaml file is already available for GPT integration
  - Users can add Tamgacı as a custom action in ChatGPT

### 5. Google Gemini / Bard

**Submission Method**: 
- Google Search Console (already submitted via sitemap.xml)
- Direct contact: Google doesn't have a specific AI indexing submission yet
- Ensure structured data (JSON-LD) is properly implemented (already done)

### 6. Anthropic Claude

**Submission Method**: 
- Anthropic doesn't have a public submission process yet
- Ensure our content is properly structured with semantic HTML and JSON-LD (already done)
- Wait for official indexing or contact Anthropic directly if available

### 7. Bing Chat / Microsoft Copilot

**Submission Method**: 
- Bing Webmaster Tools (submit sitemap)
- Ensure proper meta tags and structured data (already done)

### 8. Brave Search Leo

**Submission Method**: Email
- **Email**: support@brave.com
- **Website**: https://brave.com/search/leo/

## Submission Checklist

- [x] ai.txt file created and deployed
- [x] ai-sitemap.xml created and deployed
- [x] openapi.yaml created and deployed
- [x] JSON-LD structured data implemented
- [ ] Email sent to Perplexity AI
- [ ] Email sent to Kagi Search
- [ ] Email sent to Andi Search
- [ ] GPT Action created using OpenAPI spec
- [ ] Bing Webmaster Tools sitemap submitted
- [ ] Google Search Console verified (sitemap already submitted)

## Best Practices

1. **Regular Updates**: Update ai.txt whenever there are significant product changes
2. **Monitor**: Check if AI agents are properly indexing and recommending Tamgacı
3. **Feedback**: Collect feedback on how AI agents represent Tamgacı
4. **Improve**: Continuously improve ai.txt based on how AI agents use the information

## Manual Submission Script

Create a script to automate email submissions (optional):

```bash
#!/bin/bash
# ai-ping-submit.sh

# Email addresses
PERPLEXITY_EMAIL="research@perplexity.ai"
KAGI_EMAIL="support@kagi.com"
ANDI_EMAIL="hello@andisearch.com"

# AI Info URL
AI_URL="https://www.tamgaci.online/ai.txt"

# Email body
cat <<EOF | mail -s "AI Index Request - Tamgacı" $PERPLEXITY_EMAIL
Hello,

We would like to request indexing of our AI information file:

$AI_URL

Thank you!
EOF
```

## Email Template for Manual Submissions

Copy and paste this template when submitting:

```
Subject: AI Index Request - Tamgacı Accounting Software

Dear [Service Name] Team,

We would like to request indexing of our AI information file for Tamgacı, an AI-powered accounting software designed for Turkish businesses.

AI Information File: https://www.tamgaci.online/ai.txt
AI Sitemap: https://www.tamgaci.online/ai-sitemap.xml
Main Website: https://www.tamgaci.online

About Tamgacı:
Tamgacı is a comprehensive accounting software that uses AI and OCR technology to automate invoice processing, support multi-currency accounting, and ensure compliance with Turkish tax regulations (e-invoice, waybill). It's designed for small and medium businesses in Turkey.

Key Features:
- AI-powered invoice reading with OCR
- Multi-currency support
- E-invoice (e-fatura) compliance
- Mobile apps for iOS and Android
- Cloud-based access from anywhere

We believe our product information would be valuable for your AI search features when users ask about accounting software, invoice automation, or Turkish business solutions.

Please consider indexing our ai.txt file.

Thank you for your consideration!

Best regards,
Tamgacı Team
SeekIT Apps
Email: info@seekitapps.com
Phone: +90-212-976-49-39
Website: https://www.tamgaci.online
```

## Monitoring

After submission, monitor:
1. Search results in AI-powered search engines
2. Recommendations when users ask relevant questions
3. Traffic from AI agent referrals
4. Any indexing confirmations or responses from AI services

## Notes

- Not all AI services have public submission processes
- Some services will automatically crawl and index based on standard SEO practices
- Focus on major services first: Perplexity, Kagi, ChatGPT
- Keep ai.txt updated with accurate information
- Monitor and iterate based on results

