import json
import pathlib
import subprocess
import sys


def xcrun(*arguments):
    return json.loads(subprocess.run(["xcrun", *arguments], check=True, capture_output=True, text=True).stdout)


def test_counts(bundle):
    summary = xcrun("xcresulttool", "get", "test-results", "summary", "--path", bundle)
    tree = xcrun("xcresulttool", "get", "test-results", "tests", "--path", bundle)
    suites = []
    for plan in tree["testNodes"]:
        for test_bundle in plan.get("children", []):
            cases = [case for suite in test_bundle.get("children", []) for case in suite.get("children", []) if case.get("nodeType") == "Test Case"]
            passed = sum(1 for case in cases if case.get("result") == "Passed")
            suites.append((test_bundle["name"], len(cases), passed))
    return summary, suites


def production_module(path):
    if "/Sources/" in path:
        return path.split("/Sources/")[1].split("/")[0]
    if "/XcodeReclaim/XcodeReclaim/" in path:
        return "XcodeReclaim"
    return None


def line_coverage(bundle):
    report = xcrun("xccov", "view", "--report", "--json", bundle)
    files = {}
    for target in report["targets"]:
        for file in target["files"]:
            module = production_module(file["path"])
            if module is None:
                continue
            already_covered = files.get(file["path"], (0, 0, module))[0]
            files[file["path"]] = (max(already_covered, file["coveredLines"]), file["executableLines"], module)
    modules = {}
    for covered, executable, module in files.values():
        module_covered, module_executable = modules.get(module, (0, 0))
        modules[module] = (module_covered + covered, module_executable + executable)
    return modules


def percentage(covered, executable):
    return 100.0 * covered / executable if executable else 100.0


def coverage_colour(value):
    if value >= 95:
        return "brightgreen"
    if value >= 90:
        return "green"
    if value >= 80:
        return "yellow"
    return "red"


def badge(label, message, colour):
    return {"schemaVersion": 1, "label": label, "message": message, "color": colour}


def main(bundle, badge_folder):
    if not pathlib.Path(bundle).exists():
        print("No result bundle was produced, so there are no test or coverage figures for this run.")
        return

    summary, suites = test_counts(bundle)
    modules = line_coverage(bundle)
    passed, failed, skipped = summary["passedTests"], summary["failedTests"], summary["skippedTests"]
    seconds = summary["finishTime"] - summary["startTime"]
    covered = sum(covered for covered, _ in modules.values())
    executable = sum(executable for _, executable in modules.values())
    total = percentage(covered, executable)

    print("## Tests")
    print(f"**{passed} passed** · {failed} failed · {skipped} skipped · {seconds:.1f} s\n")
    print("| test bundle | tests | passed |")
    print("| --- | ---: | ---: |")
    for name, count, bundle_passed in suites:
        print(f"| {name} | {count} | {bundle_passed} |")
    print("\n## Coverage")
    print(f"**{total:.1f}%** of {executable:,} production lines\n")
    print("| module | covered lines | coverage |")
    print("| --- | ---: | ---: |")
    for module, (module_covered, module_executable) in sorted(modules.items()):
        print(f"| {module} | {module_covered:,} / {module_executable:,} | {percentage(module_covered, module_executable):.1f}% |")

    folder = pathlib.Path(badge_folder)
    folder.mkdir(parents=True, exist_ok=True)
    tests_message = f"{passed} passed" if failed == 0 else f"{failed} failed, {passed} passed"
    (folder / "tests.json").write_text(json.dumps(badge("tests", tests_message, "brightgreen" if failed == 0 else "red")))
    (folder / "coverage.json").write_text(json.dumps(badge("coverage", f"{total:.1f}%", coverage_colour(total))))


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])
