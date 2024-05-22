require "minitest/autorun"
require "ghx"

class DependabotCoreTest < Minitest::Test
  # The most basic test to ensure that the code loads
  def test_that_code_loads
    GHX::Dependabot::Alert.new(sample_dependabot_response)

    assert true
  end

  def sample_dependabot_response
    {
      :number => 321,
      :state => "open",
      :dependency => {
        package: {
          ecosystem: "npm",
          name: "react-pdf"
        },
        manifest_path: "yarn.lock",
        scope: "runtime"
      },
      :security_advisory => {
        ghsa_id: "GHSA-87hq-q4gp-9wr4",
        cve_id: "CVE-2024-34342",
        summary: "react-pdf vulnerable to arbitrary JavaScript execution upon opening a malicious PDF with PDF.js",
        description: "### Summary\n\nIf PDF.js is used to load a malicious PDF, and PDF.js is configured with `isEvalSupported` set to `true` (which is the default value), unrestricted attacker-controlled JavaScript will be executed in the context of the hosting domain.\n\n### Patches\n[This patch](https://github.com/wojtekmaj/react-pdf/commit/671e6eaa2e373e404040c13cc6b668fe39839cad) forces `isEvalSupported` to `false`, removing the attack vector.\n\n### Workarounds\nSet `options.isEvalSupported` to `false`, where `options` is `Document` component prop.\n\n### References\n- [GHSA-wgrm-67xf-hhpq](https://github.com/mozilla/pdf.js/security/advisories/GHSA-wgrm-67xf-hhpq)\n- https://github.com/mozilla/pdf.js/pull/18015\n- https://github.com/mozilla/pdf.js/commit/85e64b5c16c9aaef738f421733c12911a441cec6\n- https://bugzilla.mozilla.org/show_bug.cgi?id=1893645",
        severity: "high",
        identifiers: [
          {
            value: "GHSA-87hq-q4gp-9wr4",
            type: "GHSA"
          },
          {
            value: "CVE-2024-34342",
            type: "CVE"
          }
        ],
        references: [
          {
            url: "https://github.com/mozilla/pdf.js/security/advisories/GHSA-wgrm-67xf-hhpq"
          },
          {
            url: "https://github.com/wojtekmaj/react-pdf/security/advisories/GHSA-87hq-q4gp-9wr4"
          },
          {
            url: "https://nvd.nist.gov/vuln/detail/CVE-2024-34342"
          },
          {
            url: "https://github.com/mozilla/pdf.js/pull/18015"
          },
          {
            url: "https://github.com/mozilla/pdf.js/commit/85e64b5c16c9aaef738f421733c12911a441cec6"
          },
          {
            url: "https://github.com/wojtekmaj/react-pdf/commit/208f28dd47fe38c33ce4bac4205b2b0a0bb207fe"
          },
          {
            url: "https://github.com/wojtekmaj/react-pdf/commit/671e6eaa2e373e404040c13cc6b668fe39839cad"
          },
          {
            url: "https://github.com/advisories/GHSA-87hq-q4gp-9wr4"
          }
        ],
        published_at: "2024-05-07T16:48:59Z",
        updated_at: "2024-05-08T10:10:23Z",
        withdrawn_at: nil,
        vulnerabilities: [
          {
            package: {
              ecosystem: "npm",
              name: "react-pdf"
            },
            severity: "high",
            vulnerable_version_range: "< 7.7.3",
            first_patched_version: {
              identifier: "7.7.3"
            }
          },
          {
            package: {
              ecosystem: "npm",
              name: "react-pdf"
            },
            severity: "high",
            vulnerable_version_range: ">= 8.0.0, < 8.0.2",
            first_patched_version: {
              identifier: "8.0.2"
            }
          }
        ],
        cvss: {
          vector_string: "CVSS:3.1/AV:N/AC:H/PR:N/UI:R/S:U/C:H/I:H/A:L",
          score: 7.1
        },
        cwes: [
          {
            cwe_id: "CWE-79",
            name: "Improper Neutralization of Input During Web Page Generation ('Cross-site Scripting')"
          }
        ]
      },
      "security_vulnerability" => {
        "package" => {
          ecosystem: "npm",
          name: "react-pdf"
        },
        :severity => "high",
        :vulnerable_version_range => "< 7.7.3",
        :first_patched_version => {
          identifier: "7.7.3"
        }
      },
      :url => "https://api.github.com/repos/CompanyCam/Company-Cam-API/dependabot/alerts/321",
      :html_url => "https://github.com/CompanyCam/Company-Cam-API/security/dependabot/321",
      :created_at => "2024-05-07T16:54:48Z",
      :updated_at => "2024-05-07T16:54:48Z",
      :dismissed_at => nil,
      :dismissed_by => nil,
      :dismissed_reason => nil,
      :dismissed_comment => nil,
      :fixed_at => nil,
      :auto_dismissed_at => nil
    }
  end
end
